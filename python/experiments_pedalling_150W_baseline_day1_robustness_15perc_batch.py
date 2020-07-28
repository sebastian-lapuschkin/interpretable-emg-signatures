# -*- coding: utf-8 -*-
"""
Created on Tue Feb 18 13:57:34 2020

@author: horst
"""

### SVMs
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a SvmLinearL2C1em1')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a SvmLinearL2C1e0')
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a SvmLinearL2C1em2')
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a SvmLinearL2C5em2')
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a SvmLinearL2C1em3')
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a SvmLinearL2C5em3')
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a SvmLinearL2C1ep1')

### MLP Linear
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a MlpLinear')	

### MLPs 2 Layer
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer64Unit')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer128Unit')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer256Unit')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer512Unit')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer768Unit')	

### MLPs 2 Layer Tanh
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer64Unit_Tanh')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer128Unit_Tanh')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer256Unit_Tanh')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer512Unit_Tanh')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp2Layer768Unit_Tanh')	

### MLPs 3 Layer
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer64Unit')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer128Unit')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer256Unit')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer512Unit')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer768Unit')	

### MLPs 3 Layer Tanh
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer64Unit_Tanh')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer128Unit_Tanh')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer256Unit_Tanh')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer512Unit_Tanh')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Mlp3Layer768Unit_Tanh')	

### CNNs
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Cnn1DC3')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Cnn1DC6')	
runfile('experiments_setup.py', args='-d ./data/Data_Pedalling_150W_Baseline_Day1 ./data/Data_Pedalling_15perc_Robustness_Day1 -o ./output/Data_Pedalling_150W_Baseline_Day1-Data_Pedalling_15perc_Robustness_Day1 -a Cnn1DC8')	
