
'''
@author: Sebastian Lapuschkin, Fabian Horst
@maintainer: Sebastian Lapuschkin, Fabian Horst
@contact: sebastian.lapuschkin@hhi.fraunhofer.de, horst@uni-mainz.de
@version: 1.0
@copyright: Copyright (c) 2020, Sebastian Lapuschkin, Fabian Horst
@license : BSD-2-Clause
'''

import argparse
import datetime
import os
import sys

import numpy
import numpy as numpy # no cupy import here, stay on the CPU in the main script.

import scipy.io as scio # scientific python package, which supports mat-file IO within python
import helpers
import eval_score_logs
import datetime

import model
from model import *
from model.base import ModelArchitecture, ModelTraining
import train_test_cycle         #import main loop

current_datetime = datetime.datetime.now()
#setting up an argument parser for controllalbe command line calls
import argparse
parser = argparse.ArgumentParser(description="Train and evaluate Models on human EMG recordings!")
parser.add_argument('-d',  '--data_path', type=str, default='./data/Data_Baseline_Normed_V1_4_7Ps.mat', help='Sets the path to the dataset mat-file to be processed')
parser.add_argument('-o',  '--output_dir', type=str, default='./output', help='Sets the output directory root for models and results. Default: "./output"')
parser.add_argument('-me', '--model_exists', type=str, default='skip', help='Sets the behavior of the code in case a model file has been found at the output location. "skip" (default) skips remaining execution loop and does nothing. "retrain" trains the model anew. "evaluate" only evaluates the model with test data')
parser.add_argument('-rs', '--random_seed', type=int, default=1234, help='Sets a random seed for the random number generator. Default: 1234')
parser.add_argument('-s',  '--splits', type=int, default=10, help='The number of splits to divide the data into. Default: 10')
parser.add_argument('-ees','--enforce_equal_splits', type=helpers.str2bool, default=False, help='Whether to enforce equally sized splits (per class). Useful in combination with --equalize_population')
parser.add_argument('-ep', '--equalize_population', type=helpers.str2bool, default=False, help='Equalize the data population by truncating overpopulated classes?')
parser.add_argument('-a',  '--architecture', type=str, default='SvmLinearL2C1e0', help='The name of the model architecture to use/train/evaluate. Can be any joint-specialization of model.base.ModelArchitecture and model.base.ModelTraining. Default: SvmLinearL2C1e0 ')
parser.add_argument('-tp', '--training_programme', type=str, default=None, help='The training regime for the (NN) model to follow. Can be any class from model.training or any class implementing model.base.ModelTraining. The default value None executes the training specified for the NN model as part of the class definition.')
parser.add_argument('-dn', '--data_name', type=str, default='GRF_AV', help='The feature name of the data behind --data_path to be processed. Default: GRF_AV')
parser.add_argument('-tn', '--target_name', type=str, default='Subject', help='The target type of the data behind --data_path to be processed. Default: Injury')
parser.add_argument('-sd', '--save_data', type=helpers.str2bool, default=True, help='Whether to save the training and split data at the output directory root or not. Default: True')
parser.add_argument('-ft', '--force_training_device', type=str, default=None, help='Force training to be performed on a specific device, despite the default chosen numeric backend? Options: cpu, gpu, None. Default: None: Pick as defined in model definition.')
parser.add_argument('-fe', '--force_evaluation_device', type=str, default=None, help='Force evaluat to be performed on a specific device, despite the default chosen numeric backend? Options: cpu, gpu, None. Default: None. NOTE: Execution on GPU is beneficial in almost all cases, due to the massive across-batch-parallelism.')
parser.add_argument('-rc', '--record_call', type=helpers.str2bool, default=False, help='Whether to record the current call to this script in an ouput file specified via -rf or --record-file. Default: False. Only records in case the script terminates gracefully')
parser.add_argument('-rf', '--record_file', type=str, default='./command_history.txt', help='Determines the file name into which the current call to this script is recorded')
ARGS = parser.parse_args()


################################
#           "Main"
################################

#TODO: ISOLATE DATA LOADING INTO CLASS

#load matlab data as dictionary using scipy
gaitdata = scio.loadmat(ARGS.data_path)

# Feature -> Bodenreaktionskraft
X_GRF_AV = gaitdata['Feature']
Label_GRF_AV = gaitdata['Feature_EMG_Label'][0][0]   # x 6 channel label

#transposing axes, to obtain N x time x channel axis ordering, as in Horst et al. 2019
X_GRF_AV = numpy.transpose(X_GRF_AV, [0, 2, 1])         # N x 101 x 6

Y = gaitdata['Target_Subject']                  # N x S, binary labels

#
# TODO: REMOVE DATA LOADING AND BELOW DATA EXTENSION HACK WITH LOADING OF PROPER DATA!
#
# NOTE: extended toy data
import numpy as np
#X_GRF_AV = np.concatenate([X_GRF_AV, X_GRF_AV], axis=1)[:,0:200,:] # N x 200 x 6
#X_GRF_AV = np.concatenate([X_GRF_AV, X_GRF_AV[...,:2]], axis=2) # N x 200 x 8
#Label_GRF_AV = np.concatenate([Label_GRF_AV,Label_GRF_AV[...,:2]], axis=0) # extend channel labels
#Y =  np.array([Y[:,i*10:i*10+10].sum(axis=1)>0 for i in range(20)]).T #aggregate subject labels into 20 groups of 10(ish) classes
print('toy data shape:', X_GRF_AV.shape, Y.shape)
# END OF (Toy) DATA EXTENSION. Put real data here please.


X = X_GRF_AV       # prepare copy of data for each label type (due to introduced cleaning)
print(Y.shape, Y.sum(axis=0))

# remove labels/class information without data
Y = helpers.trim_empty_classes(Y)

# force class population euqlity, if desired
if ARGS.equalize_population:
    X_Injury, Y = helpers.equalize_population(X, Y, 'crop')
print(Y.shape, Y.sum(axis=0))

# split data for experiments.
IndexSplits, Permutation = helpers.create_index_splits(Y, splits=ARGS.splits, seed=ARGS.random_seed, enforce_equal_splits=ARGS.enforce_equal_splits)
#apply the permutation to the given data for the inputs and labels to match the splits again
X = X[Permutation, ...]
Y = Y[Permutation, ...]


arch = ARGS.architecture
if isinstance(arch, ModelArchitecture) and isinstance(arch, ModelTraining):
    pass # already a valid class
elif isinstance(arch,str):
    #try to get class from string name
    arch = model.get_architecture(arch)
else:
    raise ValueError('Invalid command line argument type {} for "architecture'.format(type(arch)))

training_regime =  ARGS.training_programme
if training_regime is None or isinstance(training_regime, ModelTraining):
    pass #default training behavior of the architecture class, or training class
elif isinstance(training_regime, str):
    if training_regime.lower() == 'none':
        training_regime = None #default training behavior of the architecture class, or training class
    else:
        training_regime = model.training.get_training(training_regime)
    #try to get class from string name

#register and then select available features
#TODO: REFACTOR INTO A DATA LOADING CLASS once there is more than one valid feature type
X, X_channel_labels = {'GRF_AV': (X, Label_GRF_AV)}[ARGS.data_name]

#register and then select available targets
#TODO: REFACTOR INTO A DATA LOADING CLASS
Y, Y_splits = {'Subject': (Y, IndexSplits)}[ARGS.target_name]

# this load of parameters could also be packed into a dict and thenn passed as **param_dict, if this were to be automated further.
train_test_cycle.run_train_test_cycle(
        X=X,
        Y=Y,
        L=X_channel_labels,
        LS=Y,
        S=Y_splits,
        P=Permutation,
        model_class=arch,
        output_root_dir=ARGS.output_dir,
        data_name=ARGS.data_name,
        target_name=ARGS.target_name,
        save_data_in_output_dir=ARGS.save_data,
        training_programme=training_regime, # model training behavio can be exchanged (for NNs), eg by using NeuralNetworkTrainingQuickTest instead of None. define new behaviors in model.training.py!
        do_this_if_model_exists=ARGS.model_exists,
        force_device_for_training=ARGS.force_training_device,
        force_device_for_evaluation=ARGS.force_evaluation_device # computing heatmaps on gpu is always worth it for any model. requires a gpu, obviously
)
eval_score_logs.run(ARGS.output_dir)

#record function call and parameters if we arrived here

if ARGS.record_call:
    print('Recording current call configuration to {}'.format(ARGS.record_file))
    helpers.ensure_dir_exists(os.path.dirname(ARGS.record_file))
    with open(ARGS.record_file, 'a') as f:
        argline = ' '.join(['--{} {}'.format(a, getattr(ARGS,a)) for a in vars(ARGS)])
        line = '{} : python {} {}'.format(current_datetime,
                                       sys.modules[__name__].__file__,
                                       argline)
        f.write('{}\n\n'.format(line))
