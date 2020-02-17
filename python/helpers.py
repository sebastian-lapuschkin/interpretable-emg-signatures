
import os
import argparse

import importlib.util as imp
import numpy
if imp.find_spec("cupy"): import cupy



def str2bool(value):
    """
    Helper fxn for argument parsing from command line
    """
    true_vals = ['1', 't', 'true', 'y', 'yes', 'please']
    false_vals = ['0', 'f', 'false', 'n', 'no', 'ohgod']

    if isinstance(value, bool):
        return value
    elif isinstance(value, (int, float)):
        return value > 0
    elif value.lower() in true_vals:
        return True
    elif value.lower() in false_vals:
        return False
    else:
        raise argparse.ArgumentTypeError("Invalid boolean argument '{}'. Please stick to values from '{}'".format(value, true_vals + false_vals))

def create_index_splits(Y, splits = 10, seed=None, enforce_equal_splits=False):
    """ this method subdivides the given labels into optimal groups

        for the subject prediction labels, it divides the indices into equally sized groups,
        each containing equally many samples of each person.

        for the gender prediction labels (gender is linked to subject obviously) the
        data is split into partitions where no subject can reoccur
    """

    N, P = Y.shape

    assert splits > 3, 'At least three splits required'
    if enforce_equal_splits:
        assert Y.shape[0]/splits == Y.shape[0]//splits, "Splits can not be created evenly in size if split count {} does not divide data count {} evenly".format(splits, Y.shape[0])

    samples_per_class = Y.sum(axis=0)
    assert numpy.all(samples_per_class >= splits), "Can not split data meaningfully, if smallest class size {} < number of splits {}".format(samples_per_class.min(), splits)

    #create global permutation sequence
    Permutation = numpy.arange(N)

    if seed is not None: #reseed the random generator
        numpy.random.seed(seed)
        Permutation = numpy.random.permutation(Permutation)

    #permute label matrices. also return this thing!
    Y = Y[Permutation,...]

    #initialize index lists
    SubjectIndexSplits = [None]*splits

    # create a split over subject labels by iterating over all person labels and subdividing them as equally as possible.
    for i in range(P):
        pIndices = numpy.where(Y[:,i] == 1)[0]

        #compute an approx equally sized partitioning.
        partitioning = numpy.linspace(0, len(pIndices), splits+1, dtype=int)
        for si in range(splits):
            #make sure index lists exist
            if SubjectIndexSplits[si] is None:
                SubjectIndexSplits[si] = []

            #spread subject label across those index lists
            if si == splits-1:
                #the last group.
                SubjectIndexSplits[si].extend(pIndices[partitioning[si]:])
            else:
                SubjectIndexSplits[si].extend(pIndices[partitioning[si]:partitioning[si+1]])


    assert numpy.unique([len(s) for s in SubjectIndexSplits]).size == 1, "Not all splits have equally many samples: n={}".format([len(s) for s in SubjectIndexSplits])
    #return the indices for the subject recognition training, the gender recognition training and the original permutation to be applied on the data.
    return SubjectIndexSplits, Permutation


def convIOdims(D,F,S):
    #helper method for computing output dims of 2d convolutions when giving D as data shape, F as filter shape and S as stride
    #D, F and S are expected to be scalar values
    D = float(D)
    F = float(F)
    S = float(S)
    return (D-F)/S + 1


def ensure_dir_exists(path_to_dir):
    if not os.path.isdir(path_to_dir):
        print('Target directory {} does not exist. Creating.'.format(path_to_dir))
        os.makedirs(path_to_dir)
    # else:
    #    print('Target directory {} exists.'.format(path_to_dir))

def trim_empty_classes(Y):
    # expects an input array shaped N x C. removes label columns for classes without samples.
    n_per_col = Y.sum(axis=0)
    empty_cols = n_per_col == 0
    if numpy.any(empty_cols):
        print('{} Empty columns detected in label matrix shaped {}. Columns are: {}. Removing.'.format(empty_cols.sum(), Y.shape, numpy.where(empty_cols)[0]))
        Y = Y[:,~empty_cols]
        print('    shape is {} post column removal.'.format(Y.shape))
        return Y
    else:
        print('No empty columns detected in label matrix shaped {}'.format(Y.shape))
        return Y

def equalize_population(X, Y, mode='crop'):
    """
    Equalize data population across classes.

    Parmeters:
    ----------
    Y   --  numpy.array -- label array shaped N x C
    X   --  numpy.array -- data array shaped  N x D
    mode -- str -- euqualization mode. Currently only 'crop' is implemented, which undersamples the classes by removing highest indices from overpopulated classes
    """

    y_shape_pre = Y.shape
    x_shape_pre = X.shape

    samples_per_class = Y.sum(axis=0)
    smallest_class_size = samples_per_class.min()

    imbalanced_classes = numpy.where(samples_per_class > smallest_class_size)[0]

    if imbalanced_classes.size > 0:
        print('imbalanced classes detected: {}'.format(imbalanced_classes))
        print('number of classes c={} | smallest class s={} | imbalanced classes n={}'.format(Y.shape[1], smallest_class_size, samples_per_class[imbalanced_classes]))
        print('balancing by performing "{}"'.format(mode))
        if mode == 'crop':
            # remove samples from overpopulated classes by truncation
            # build binary array of samples to keep to avoid data permutation
            keep = numpy.ones((Y.shape[0]), dtype=bool)
            for clzz in imbalanced_classes:
                samples_to_remove = samples_per_class[clzz] - smallest_class_size
                print('cropping {} samples from class {}'.format(samples_to_remove, clzz))
                #set last samples_to_remove of affected class in keep to 0
                keep[numpy.where((Y[:,clzz] > 0))[0][smallest_class_size::]] = 0

            # crop array and data matrix
            X = X[keep, ...]
            Y = Y[keep, ...]

    # nothing to do here
    assert numpy.all(x_shape_pre[1::] == X.shape[1::]), 'Number of features in X changed during data rebalancing! should not have happened!'
    assert numpy.all(y_shape_pre[1::] == Y.shape[1::]), 'Number of classes in Y changed during data rebalancing! should not have happened!'
    return X, Y


def arrays_to_cupy(*args):
    assert imp.find_spec("cupy"), "module cupy not found/installed."
    return tuple([cupy.array(a) for a in args])

def arrays_to_numpy(*args):
    if not imp.find_spec("cupy"): #cupy has not been installed and imported -> arrays should be numpy
        return args
    else:
        return tuple([cupy.asnumpy(a) for a in args])


def force_device(model, arrays, device=None):
    #enforces the use of a specific device (cpu or gpu) for given models or arrays
    #converts the model in-place
    #returns the transferred arrays
    if device is None:
        return arrays
    elif isinstance(device, str) and device.lower() == 'none':
        return arrays
    elif isinstance(device, str) and device.lower() == 'cpu':
        print('Forcing model and associated arrays to CPU')
        model.to_cpu()
        return arrays_to_numpy(*arrays)
    elif isinstance(device, str) and device.lower() == 'gpu':
        print('Forcing model and associated arrays to GPU')
        assert imp.find_spec("cupy") is not None, "Model can not be forced to execute on GPU device. No GPU device present"
        model.to_gpu()
        return arrays_to_cupy(*arrays)
    else:
        raise ValueError("Unsure how to interpret input value '{}' in helpers.force_device".format(device))

def get_channel_wise_bounds(array):
    """
    Returns the channel-wise lower and upper bounds of some data, assuming a shape of
    (batchsize, [feature dims])

    Parameters:
    -----------
    array - numpy or cupy array of floats shaped (N, ...)


    Returns:
    --------
    tuple of arrays (lower, upper), each shaped (1, ...)
        the returned arrays are in CPU-accessible memory (ie numpy type arrays)
    """
    array = arrays_to_numpy(array)[0]
    lower = numpy.amin(array, axis=0, keepdims=True)
    upper = numpy.amax(array, axis=0, keepdims=True)
    return (lower, upper)

def l1loss(y_test, y_pred):
    return numpy.abs(y_pred - y_test).sum()/y_test.shape[0]

def accuracy(y_test, y_pred):
    y_test = numpy.argmax(y_test, axis=1)
    y_pred = numpy.argmax(y_pred, axis=1)
    return numpy.mean(y_test == y_pred)