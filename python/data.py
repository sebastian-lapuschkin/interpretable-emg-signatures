

import numpy
import scipy.io as scio # scientific python package, which supports mat-file IO within python
import helpers

def load_and_prepare(ARGS):
    """
    Loads and prepares data for execution

    Parameters:
    -----------

    args -- argparse.Namespace : argument container with all the info you need.
    """

    #load matlab data as dictionary using scipy
    gaitdata = scio.loadmat(ARGS.data_path)

    # Feature -> Bodenreaktionskraft
    X = gaitdata['Feature']
    X_channel_labels = gaitdata['Feature_EMG_Label'][0][0]      # x 8 channel label

    #transposing axes, to obtain N x time x channel axis ordering, as in Horst et al. 2019
    X = numpy.transpose(X, [0, 2, 1])         # N x 200 x 8

    Y = gaitdata['Target_Subject']                          # N x S, binary labels

    print('Data shape:', X.shape, Y.shape)


    # remove labels/class information without data
    Y = helpers.trim_empty_classes(Y)

    # force class population euqlity, if desired
    if ARGS.equalize_population:
        X, Y = helpers.equalize_population(X, Y, 'crop')
    print('Class population', Y.shape, Y.sum(axis=0))

    # split data for experiments.
    IndexSplits, Permutation = helpers.create_index_splits(Y, splits=ARGS.splits, seed=ARGS.random_seed, enforce_equal_splits=ARGS.enforce_equal_splits)
    #apply the permutation to the given data for the inputs and labels to match the splits again
    X = X[Permutation, ...]
    Y = Y[Permutation, ...]

    return X, Y, X_channel_labels, IndexSplits, Permutation


