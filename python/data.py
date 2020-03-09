

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

    loaded_data = { 'X':None,
                    'Y':None,
                    'X_channel_labels':None,
                    'IndexSplits':None,
                    'Permutation':None,
                    #
                    'X_train':None,
                    'X_train_channel_labels':None,
                    'Y_train':None,
                    'X_test':None,
                    'X_test_channel_labels':None,
                    'Y_test':None,
                    'X_val':None,
                    'X_val_channel_labels':None,
                    'Y_val':None,
                    }

    if isinstance(ARGS.data_path, str) or (isinstance(ARGS.data_path, list) and len(ARGS.data_path) == 1):
        print('One single distinct data path given. Loading data and creating splits')
        #load data "as usual" and prepare splits
        #load matlab data as dictionary using scipy
        path = ARGS.data_path if isinstance(ARGS.data_path, str) else ARGS.data_path[0]
        gaitdata = scio.loadmat(path)

        X = gaitdata['Feature']
        X_channel_labels = gaitdata['Feature_EMG_Label'][0][0] # x 8 channel label

        #transposing axes, to obtain N x time x channel axis ordering, as in Horst et al. 2019
        X = numpy.transpose(X, [0, 2, 1])         # N x 200 x 8
        Y = gaitdata['Target_Subject']            # N x S, binary labels

        print('Data shape:', X.shape, Y.shape)
        print('Data channels:', X_channel_labels)

        # remove labels/class information without data
        Y = helpers.trim_empty_classes(Y)

        # force class population euqlity, if desired
        if ARGS.equalize_population:
            X, Y = helpers.equalize_population(X, Y, 'crop')
        print('Class population', Y.shape, Y.sum(axis=0))

        # split data for experiments.
        IndexSplits, Permutation = helpers.create_index_splits(Y, splits=ARGS.splits, seed=ARGS.random_seed, enforce_equal_splits=ARGS.enforce_equal_splits)
        # apply the permutation to the given data for the inputs and labels to match the splits again
        X = X[Permutation, ...]
        Y = Y[Permutation, ...]

        # package data for delivery
        loaded_data['X'] = X
        loaded_data['Y'] = Y
        loaded_data['X_channel_labels'] = X_channel_labels
        loaded_data['IndexSplits'] = IndexSplits
        loaded_data['Permutation'] = Permutation


    elif len(ARGS.data_path) == 3:
        print('Three distinct data paths given. Loading Training, Test and Validation data')

        train_data = scio.loadmat(ARGS.data_path[0])
        X_train = train_data['Feature']
        X_train_channel_labels = train_data['Feature_EMG_Label'][0][0] # are those required?
        Y_train_data = train_data['Target_Subject']

        test_data  = scio.loadmat(ARGS.data_path[1])
        X_test = test_data['Feature']
        X_test_channel_labels = test_data['Feature_EMG_Label'][0][0] # are those required?
        Y_test_data = test_data['Target_Subject']

        val_data   = scio.loadmat(ARGS.data_path[2])
        X_val = val_data['Feature']
        X_val_channel_labels = val_data['Feature_EMG_Label'][0][0] # are those required?
        Y_val_data = val_data['Target_Subject']

        # ASSERTIONS

        # all data must have three axes: N, time, channels
        assert len(X_train.shape) == 3, "Number of training data axes must be 3, but was {}".format(len(X_train.shape))
        assert len(X_test.shape) == 3, "Number of test data axes must be 3, but was {}".format(len(X_test.shape))
        assert len(X_val.shape) == 3, "Number of validation data axes must be 3, but was {}".format(len(X_val.shape))

        # number of dimensions must be the same in all datasets
        assert X_train.shape[1::] == X_test.shape[1::], "Mismatch between training sample shape and test sample shape: {} vs {}".format(X_train.shape[1::], X_test.shape[1::])
        assert X_train.shape[1::] == X_val.shape[1::], "Mismatch between validation sample shape and test sample shape: {} vs {}".format(X_train.shape[1::], X_val.shape[1::])

        # number of classes must be the same in all datasets
        assert Y_train_data.shape[1] == Y_test_data.shape[1], "Mismatch between class count between training and test data: {} vs {}".format(Y_train_data.shape[1], Y_test_data.shape[1])
        assert Y_train_data.shape[1] == Y_val_data.shape[1], "Mismatch between class count between training and validation data: {} vs {}".format(Y_train_data.shape[1], Y_val_data.shape[1])

        # set of channel labels must be the same in all datasets
        assert numpy.all(X_train_channel_labels == X_test_channel_labels), "Mismatch between training and test channel labels: {} vs {}".format(X_train_channel_labels, X_test_channel_labels)
        assert numpy.all(X_train_channel_labels == X_val_channel_labels), "Mismatch between training and validation channel labels: {} vs {}".format(X_train_channel_labels, X_val_channel_labels)

        #  we do not want any empty classes in the training data.
        assert numpy.all(Y_train_data.sum(axis=0) > 0), "Empty class detected in training set! Class counts are: {}".format(Y_train_data.sum(axis=0))

        # we are fine here. continue processing
        # transposing axes, to obtain N x time x channel axis ordering, as in Horst et al. 2019
        X_train = numpy.transpose(X_train, [0, 2, 1])         # N x 200 x 8
        X_test = numpy.transpose(X_test, [0, 2, 1])         # N x 200 x 8
        X_val = numpy.transpose(X_val, [0, 2, 1])             # N x 200 x 8


        print('Training data shape:', X_train.shape, Y_train_data.shape)
        print('Training data channels:', X_train_channel_labels)
        print('Training class population', Y_train_data.shape, Y_train_data.sum(axis=0))
        print()
        print('Test data shape:', X_test.shape, Y_test_data.shape)
        print('Test data channels:', X_test_channel_labels)
        print('Test class population', Y_test_data.shape, Y_test_data.sum(axis=0))
        print()
        print('Validation data shape:', X_val.shape, Y_val_data.shape)
        print('Validation data channels:', X_val_channel_labels)
        print('Validation class population', Y_val_data.shape, Y_val_data.sum(axis=0))

        # package data for delivery
        loaded_data['X_train'] = X_train
        loaded_data['X_train_channel_labels'] = X_train_channel_labels
        loaded_data['Y_train'] = Y_train_data
        #
        loaded_data['X_test'] = X_test
        loaded_data['X_test_channel_labels'] = X_test_channel_labels
        loaded_data['Y_test'] = Y_test_data
        #
        loaded_data['X_val'] = X_val
        loaded_data['X_val_channel_labels'] = X_val_channel_labels
        loaded_data['Y_val'] = Y_val_data


    elif len(ARGS.data_path) == 2:
        print('Two distinct data paths given. Loading Training and Test data. Using Training data for validation')

        train_data = scio.loadmat(ARGS.data_path[0])
        X_train = train_data['Feature']
        X_train_channel_labels = train_data['Feature_EMG_Label'][0][0] # are those required?
        Y_train_data = train_data['Target_Subject']

        test_data  = scio.loadmat(ARGS.data_path[1])
        X_test = test_data['Feature']
        X_test_channel_labels = test_data['Feature_EMG_Label'][0][0] # are those required?
        Y_test_data = test_data['Target_Subject']

        # ASSERTIONS

        # all data must have three axes: N, time, channels
        assert len(X_train.shape) == 3, "Number of training data axes must be 3, but was {}".format(len(X_train.shape))
        assert len(X_test.shape) == 3, "Number of test data axes must be 3, but was {}".format(len(X_test.shape))

        # number of dimensions must be the same in all datasets
        assert X_train.shape[1::] == X_test.shape[1::], "Mismatch between training sample shape and test sample shape: {} vs {}".format(X_train.shape[1::], X_test.shape[1::])

        # number of classes must be the same in all datasets
        assert Y_train_data.shape[1] == Y_test_data.shape[1], "Mismatch between class count between training and test data: {} vs {}".format(Y_train_data.shape[1], Y_test_data.shape[1])

        # set of channel labels must be the same in all datasets
        assert numpy.all(X_train_channel_labels == X_test_channel_labels), "Mismatch between training and test channel labels: {} vs {}".format(X_train_channel_labels, X_test_channel_labels)

        #  we do not want any empty classes in the training data.
        assert numpy.all(Y_train_data.sum(axis=0) > 0), "Empty class detected in training set! Class counts are: {}".format(Y_train_data.sum(axis=0))

        # we are fine here. continue processing
        # transposing axes, to obtain N x time x channel axis ordering, as in Horst et al. 2019
        X_train = numpy.transpose(X_train, [0, 2, 1])         # N x 200 x 8
        X_test = numpy.transpose(X_test, [0, 2, 1])         # N x 200 x 8


        print('Training/Validation data shape:', X_train.shape, Y_train_data.shape)
        print('Training/Validation data channels:', X_train_channel_labels)
        print('Training/Validation class population', Y_train_data.shape, Y_train_data.sum(axis=0))
        print()
        print('Test data shape:', X_test.shape, Y_test_data.shape)
        print('Test data channels:', X_test_channel_labels)
        print('Test class population', Y_test_data.shape, Y_test_data.sum(axis=0))

        # package data for delivery
        loaded_data['X_train'] = X_train
        loaded_data['X_train_channel_labels'] = X_train_channel_labels
        loaded_data['Y_train'] = Y_train_data
        #
        loaded_data['X_test'] = X_test
        loaded_data['X_test_channel_labels'] = X_test_channel_labels
        loaded_data['Y_test'] = Y_test_data
        #
        loaded_data['X_val'] = X_train + 0      # this creates a value copy of X_train to use as the validation set
        loaded_data['X_val_channel_labels'] = X_train_channel_labels
        loaded_data['Y_val'] = Y_train_data + 0 # copy data by (not) manipulating it


    # make a dict with all necessary info in there
    return loaded_data


