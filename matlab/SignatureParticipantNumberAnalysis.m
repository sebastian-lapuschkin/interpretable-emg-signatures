%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Script used to compare signatures from models with different number of participants used for training
%%%%%   By Dr Jeroen Aeles, Dr Fabian Horst, Dr Sebastian Lapuschkin, Dr Lilian Lacourpaille, Dr François Hug
%%%%%   Last edited on 23 July 2020
%%%%%   The script uses the input variables from XXX
%%%%%   The figures in the script refer to the paper below
%%%%%   XXX
%%%%%
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Numerical analyses
 % Compare data from same participants across results with different
 % subsamples for model training

   clear all
   close all
   clc
   
 % Load data
    main_dir = 'C:\';
    cd(main_dir);
    Cnd = 'Cycling';
    foldrs = dir;
    foldrs(1:2,:) = [];
    
  for Btch = 1:length(foldrs) 
    clearvars -except foldrs Btch main_dir Cnd
    Cnrtfol = foldrs(Btch).name
    liste = dir(fullfile(main_dir,Cnrtfol,'*.mat'));
    new_dir = strcat(main_dir,Cnrtfol);
    cd(new_dir);
    files = {liste.name};
    flnrs = length(files);
    BtchIdx = strfind(Cnrtfol,'V3_');
    BtchIdx2 = strfind(Cnrtfol,'_Subj');
    BtchNme_pre = Cnrtfol(BtchIdx+3:BtchIdx2-1);
    BtchIdx3 = strfind(BtchNme_pre,'-');
    BtchNme = strcat(BtchNme_pre(1:BtchIdx3-1),'_',BtchNme_pre(BtchIdx3+1:end));
    

  %% Organise data
    for i = 1:flnrs
        flnme = liste(i).name;
        idxx = strfind(flnme,'P');
        idxx2 = strfind(flnme,'Subject');
        
          load(files{i})
          AllFiles.(char(Cnd)).(char(BtchNme)).(char(flnme(idxx:idxx2-1))).Rpred_Output = RpredAct_Output;
          AllFiles.(char(Cnd)).(char(BtchNme)).(char(flnme(idxx:idxx2-1))).Feature_Output = Feature_Output;
          
          clearvars flnme idxx idxx2 RpredAct_Output Feature_Output Yact_Output Ypred_Output
    end

    flnms2 = fieldnames(AllFiles.(char(Cnd)).(char(BtchNme)));
    for i = 1:flnrs
        flnme = char(flnms2(i));
        idxx = strfind(flnme,'N');
        idxx2 = strfind(flnme,'S');
        idxx3 = strfind(flnme,'P');
        Subjjnme = flnme(idxx3:(idxx-2));        
        Grpnme = flnme(idxx:(idxx2-2));
        Testnme = flnme(idxx2:end);
        
          FilesPerGroup.(char(Cnd)).(char(BtchNme)).(char(Subjjnme)).(char(Grpnme)).(char(Testnme)) = AllFiles.(char(Cnd)).(char(BtchNme)).(char(flnms2(i)));
          
          clearvars flnme idxx idxx2 RpredAct_Output Feature_Output Yact_Output Ypred_Output Grpnme Testnme
    end    
    NrSbjGrps = length(fieldnames(FilesPerGroup.(char(Cnd)).(char(BtchNme))));
    Sbsnmes = fieldnames(FilesPerGroup.(char(Cnd)).(char(BtchNme)));
    tmpnme = fieldnames(FilesPerGroup.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(1))));
    NrGroups = length(tmpnme);
    Grpnmes = tmpnme;
    NrTests = 10;
    NrSbjs = 10;
    Testnmes = fieldnames(FilesPerGroup.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(1))).(char(Grpnmes(1))));
    clearvars files flnms2 i liste flnrs
    
    
 % Remove all other participants
   for Sbs = 1:NrSbjGrps
       for Grps = 1:NrGroups
           for Tsts = 1:NrTests    
                FilesPerGroup.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).Rpred_Output(:,2:end) = [] ;
                FilesPerGroup.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).Feature_Output(:,2:end) = [] ;
           end
       end
   end

 % Pre-process data: remove negatives & normalise, re-structure
   for Sbs = 1:NrSbjGrps 
       for Grps = 1:NrGroups
           for Tsts = 1:NrTests
               RpredAct_Output = FilesPerGroup.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).Rpred_Output;
               Feature_Output = FilesPerGroup.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).Feature_Output;

                 % remove all negative relevance values (make NaN) & normalise   
                    Rpred_Output_pre = RpredAct_Output;
                    for k=1:size(Rpred_Output_pre,2)  
                        if isempty(Rpred_Output_pre{k}) == 1
                        else              
                         Rpred_Output_pre{k}(Rpred_Output_pre{k}<0) = NaN;       

                            % normalise relevance values within each cycle (0 to 1)
                            for m=1:size(Rpred_Output_pre{k},1)
                                maxx = max(Rpred_Output_pre{k}(m,:));

                                for l = 1:length(Rpred_Output_pre{k})
                                    Rpred_Output{k}(m,l) = (Rpred_Output_pre{k}(m,l) .*(1/maxx)) ;
                                end
                            end
                        end
                    end

                 % Restructure most relevant data (SVM linear)
                    for k = 1:size(Rpred_Output_pre,2)  
                        if isempty(Rpred_Output_pre{k}) == 1
                        else           
                            for l = 1:30
                                Relevance_data.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).(char(['Cycle',num2str(l)])) = Rpred_Output{k}(l,:);
                                MuscleActivation_data.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).(char(['Cycle',num2str(l)])) = Feature_Output{k}(l,:);
                                GtlR_temp(l,:) = Rpred_Output{k}(l,:);
                                GtlMA_temp(l,:) = Feature_Output{k}(l,:);
                            end
                            for i = 1:1600
                                Relevance_data.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).(char('nanmean'))(1,i) = nanmean(GtlR_temp(:,i));
                                MuscleActivation_data.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).(char('nanmean'))(1,i) = nanmean(GtlMA_temp(:,i));
                            end
                            clearvars GtlR_temp GtlMA_temp;
                        end
                    end   
                clearvars RpredAct_Output Feature_Output Rpred_Output_pre Rpred_Output
           end
       end
   end
   
 %% Robustness testing 
   % RMSE
     for Sbs = 1:NrSbjGrps 
         for Grps = 1:NrGroups
             tlr = 0;
             for Tsts = 1:NrTests 
                    % RMS for robustness data
                       CcleA = Relevance_data.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).(char('nanmean'));
                       lps = Testnmes;
                       Crntnme = (char(Testnmes(Tsts)));
                       lps(strcmp(lps,Crntnme)) = [];
                         for l = 1:length(lps)
                            CcleB = Relevance_data.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(lps(l))).(char('nanmean'));
                            tlr=tlr+1;
                            RMSE_Temp(tlr,1) = sqrt(nanmean((CcleA-CcleB).^2));
                             clearvars  CcleB                   
                         end
                      clearvars  CcleA                   
             end
           Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).RMSE = RMSE_Temp; 
           Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).RMSE_mean(1,1) = mean(RMSE_Temp); 
           RMSE_CI(1,1) = mean(RMSE_Temp) - (1.96 * (std(RMSE_Temp)/sqrt(length(RMSE_Temp))));
           RMSE_CI(1,2) = mean(RMSE_Temp) + (1.96 * (std(RMSE_Temp)/sqrt(length(RMSE_Temp))));
           Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).RMSE_CI = RMSE_CI;           
           clearvars RMSE_Temp RMSE_CI
         end
     end
        
    
   % Correlation between nanmean of each iteration per model configuration
   % and subject
     for Sbs = 1:NrSbjGrps    
         for Grps = 1:NrGroups
             tlr = 0;
             for Tsts = 1:NrTests 
                    % Correlation for robustness data
                       CcleA = Relevance_data.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(Testnmes(Tsts))).(char('nanmean'));
                       CcleA(isnan(CcleA)) = 0;
                       lps = Testnmes;
                       Crntnme = (char(Testnmes(Tsts)));
                       lps(strcmp(lps,Crntnme)) = [];
                         for l = 1:length(lps)
                            CcleB = Relevance_data.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).(char(lps(l))).(char('nanmean'));
                            CcleB(isnan(CcleB)) = 0;                        
                            tlr=tlr+1;
                            [r_pre p_pre] = corrcoef(CcleA,CcleB);
                            r(tlr,1) = r_pre(2,1);
                            clearvars CcleB r_pre p_pre                 
                         end
                      clearvars  CcleA                   
             end
           Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).Correlation = r;        
           clearvars r
        end
     end
     
  % Correlation results averaging
     NanTlr = 0;
     for Sbs = 1:NrSbjGrps      
         for Grps = 1:NrGroups
            % Find r-values at 0 lag (method suggested by Francois)
               clearvars peak_r z z_mean z_final
               peak_r = Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).Correlation;

            % Transform individual r-values to z-values (Fisher's transform)
              for i = 1:length(peak_r)
                z_temp = 0.5*log((1+peak_r(i,1))/(1-peak_r(i,1)));
                Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).Correlation_z(i,1) = z_temp;
                z(i,1) = z_temp;
                clearvars z_temp
              end

            % Calculate mean of all z-values
               z(z==inf) = NaN;
               z_mean = nanmean(z);
               z_CI(1,1) = nanmean(z) - (1.96 * (nanstd(z)/sqrt(length(z))));
               z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

            % Transform mean z-value back to r-value   
                z_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
                z_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
                z_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);
        
              Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).Correlation_r_mean = z_final;       
              Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))).Correlations_r_CI = z_final_CI; 
                if isnan(z_final) | isnan(z_final_CI)
                    NaNs_final_corr.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(Grpnmes(Grps))) = 1;
                    NanTlr = NanTlr+1;
                    NaNs_final_corr_List(NanTlr,1) = Grpnmes(Grps);
                end
              clearvars z_mean z z_CI
         end
     end

   
   % re-structure data in order of #of subjects
      for Sbs = 1:NrSbjGrps      
         S = fieldnames(Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))));
         C = natsortfiles(S);
           for k = 1:numel(C)
               Robustness_Results2.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(C(k))) = Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(Sbs))).(char(C(k)));
           end
           clearvars S C k
      end
         S = fieldnames(Robustness_Results.(char(Cnd)).(char(BtchNme)));
         C = natsortfiles(S);
           for k = 1:numel(C)
               Robustness_Results3.(char(Cnd)).(char(BtchNme)).(char(C(k))) = Robustness_Results2.(char(Cnd)).(char(BtchNme)).(char(C(k)));
           end
           clearvars S C k
            
         clearvars Robustness_Results Robustness_Results2 
         Robustness_Results = Robustness_Results3;
         Grpnmes = fieldnames(Robustness_Results.(char(Cnd)).(char(BtchNme)).(char(Sbsnmes(1))));
         clearvars Robustness_Results3 S C k i l k lps p peak_r r s z z_final z_mean tlr Tsts Grps Crntnme idxx3 m maxx NanTlr Sbs z_final_CI tmpnme Subjjnme Cnrtfol BtchIdx BtchIdx2 BtchIdx3 AllFiles FilesPerGroup
         
   % Save workspace
     Out_dir = 'C:\Users\Jeroen\Nextcloud\Projects\Machine_Learning\Matlab\Analyses\ParticipantNrTests\';
       save([Out_dir 'New_Data_Gait_ParticipantNrTest_' BtchNme '_compressed.mat']);
       clearvars Relevance_data
       save([Out_dir 'New_Data_Gait_ParticipantNrTest_' BtchNme '_ResultsOnly.mat']);
  end
     
  
 %% Combined data from all batches
  % Load data and organise
    clear
    main_dir = 'C:\Users\Jeroen\Nextcloud\Projects\Machine_Learning\Matlab\Analyses\ParticipantNrTests\Results\Gait\';
    cd(main_dir);
    Cnd = 'Gait';
    foldrs2 = dir;
    foldrs2(1:2,:) = [];
    
    for Btch = 1:length(foldrs2) 
       filenme = foldrs2(Btch).name;
       flnrs = length(filenme);
       BtchIdx = strfind(filenme,'st_P');
       BtchIdx2 = strfind(filenme,'_Res');
       BtchNme_pre = filenme(BtchIdx+3:BtchIdx2-1);
       BtchIdx3 = strfind(BtchNme_pre,'-');
       BtchNme = strcat(BtchNme_pre(1:BtchIdx3-1),'_',BtchNme_pre(BtchIdx3+1:end));         
         load(filenme)    ;
         Robustness_Results_all.(char(Cnd)).(char(BtchNme)) = Robustness_Results.(char(Cnd)).(char(BtchNme));
    end
     Btches = fieldnames(Robustness_Results_all.(char(Cnd)));
  
  % Remove N2 condition
    for Btch = 1:length(Btches)
        Sbjs = fieldnames(Robustness_Results_all.(char(Cnd)).(char(Btches(Btch))));
        for Sbj = 1:length(Sbjs)
            Robustness_Results_all.(char(Cnd)).(char(Btches(Btch))).(char(Sbjs(Sbj))) = rmfield(Robustness_Results_all.(char(Cnd)).(char(Btches(Btch))).(char(Sbjs(Sbj))),'N2');
        end
    end
    clearvars -except Robustness_Results_all Btches Cnd
    
    
 % Plot results
   % Restructure to have all data combined for each model configuration
      Grps = fieldnames(Robustness_Results_all.(char(Cnd)).(char(Btches(1))).P1);
      NrGroups = length(Grps);
      Tlr = 1;
      for Btch = 1:length(Btches)
        Sbjs = fieldnames(Robustness_Results_all.(char(Cnd)).(char(Btches(Btch))));          
         for Sbj = 1:length(Sbjs)   
            Tlr_end = Tlr - 1 + length(Robustness_Results_all.(char(Cnd)).(char(Btches(Btch))).(char(Sbjs(Sbj))).(char(Grps(1))).Correlation_z)  ;           
               for Grp = 1:NrGroups
                  Temp_z_all.(char(Cnd)).(char(Grps(Grp)))(Tlr:Tlr_end,1) = Robustness_Results_all.(char(Cnd)).(char(Btches(Btch))).(char(Sbjs(Sbj))).(char(Grps(Grp))).Correlation_z;
                  pre_z = Robustness_Results_all.(char(Cnd)).(char(Btches(Btch))).(char(Sbjs(Sbj))).(char(Grps(Grp))).Correlation_z;
                  Temp_z_all.(char(Cnd)).(char(Grps(Grp)))(Tlr,1) = nanmean(pre_z); 
                  Robustness_Results_Final.(char(Cnd)).(char(Grps(Grp))).PerSubject.(char(Sbjs(Sbj))).Correlation_r_mean = Robustness_Results_all.(char(Cnd)).(char(Btches(Btch))).(char(Sbjs(Sbj))).(char(Grps(Grp))).Correlation_r_mean;
                  Robustness_Results_Final.(char(Cnd)).(char(Grps(Grp))).PerSubject.(char(Sbjs(Sbj))).Correlation_r_CI = Robustness_Results_all.(char(Cnd)).(char(Btches(Btch))).(char(Sbjs(Sbj))).(char(Grps(Grp))).Correlations_r_CI;
               end
            Tlr = 1 + Tlr_end; 
            Tlr = Tlr+1; 
         end
      end
      
      for Grp = 1:NrGroups
            z = Temp_z_all.(char(Cnd)).(char(Grps(Grp)));
            % Calculate mean of all z-values
               z(z==inf) = NaN;
               z_mean = nanmean(z);
               z_CI(1,1) = nanmean(z) - (1.96 * (std(z)/sqrt(length(z))));
               z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

            % Transform mean z-value back to r-value   
                r_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
                r_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
                r_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);
        
              Robustness_Results_Final.(char(Cnd)).(char(Grps(Grp))).Correlation_r_mean_MeanOf90ValuesFirst = r_final;       
              Robustness_Results_Final.(char(Cnd)).(char(Grps(Grp))).Correlations_r_CI_MeanOf90ValuesFirst = r_final_CI; 
                if isnan(r_final) | isnan(r_final_CI)
                    NaNs_final_corr.(char(Cnd)).(char(Btches)).(char(Sbjs(Sbjs))).(char(Grpnmes(Grps))) = 1;
                    NanTlr = NanTlr+1;
                    NaNs_final_corr_List(NanTlr,1) = Grps(Grp);
                end
              clearvars z_mean z z_CI r_final r_final_CI
      end
      
   % Save workspace
      Out_dir = 'C:\';
      save([Out_dir 'New_Data_Gait_ParticipantNrTest_AllParticipants_ResultsOnly2a.mat']);
       
       
   % Plot results for correlations between iterations for each condition and all subjects   
     figure
      hold on     
       ylabel('r');
       xlabel('# of participants');
       set(gcf,'Color','w');        
         for Grp = 1:NrGroups
            errorbar(Grp,Robustness_Results_Final.(char(Cnd)).(char(Grps(Grp))).Correlation_r_mean(:,1),Robustness_Results_Final.(char(Cnd)).(char(Grps(Grp))).Correlation_r_mean(:,1)-Robustness_Results_Final.(char(Cnd)).(char(Grps(Grp))).Correlations_r_CI(:,1),Robustness_Results_Final.(char(Cnd)).(char(Grps(Grp))).Correlation_r_mean(:,1)-Robustness_Results_Final.(char(Cnd)).(char(Grps(Grp))).Correlations_r_CI(:,1),'-o')
         end
           xticks([1:1:NrGroups])
           xticklabels([6:4:78])
           set(gca,'FontSize',16) 
            title('robustness of individual cycles','FontSize',12)           
           ylim([0.7 1])    
    
           
           
    
 %% Comparison with baseline models
  % Load baseline data (N=78 model)
    clear
    main_dir = 'C:\';
    cd(main_dir); 
    Cnd = 'Cycling';    
     load('Data_All_Results_V5_4.mat')
     Data_BaselineModel.(char(Cnd)) = AllData.(char(Cnd)).Day1.Relevance_data;
     clearvars -except Data_BaselineModel
     

    main_dir = 'C:\';
    cd(main_dir);
    foldrs2 = dir;
    foldrs2(1:2,:) = [];
    
    
    for Btch = 1:length(foldrs2) 
       filenme = foldrs2(Btch).name
       flnrs = length(filenme);
       BtchIdx = strfind(filenme,'st_P');
       BtchIdx2 = strfind(filenme,'_Res');
       BtchNme_pre = filenme(BtchIdx+3:BtchIdx2-1);
       BtchIdx3 = strfind(BtchNme_pre,'-');
       BtchNme = strcat(BtchNme_pre(1:BtchIdx3-1),'_',BtchNme_pre(BtchIdx3+1:end));         
         load(filenme)    
         Cnd2 = 'Cycling';    
         Data_TestModels.(char(Cnd2)).(char(BtchNme)) = Relevance_data.(char(Cnd)).(char(BtchNme))
    end
     Cnd = 'Gait';    
     Btches = fieldnames(Data_TestModels.(char(Cnd)));
     Sbjs = fieldnames(Data_BaselineModel.(char(Cnd)));
%      Sbjs(79) = [];
     clearvars -except Data_BaselineModel Data_TestModels Cnd Btches Sbjs
 
     for Btc = 1:length(fieldnames(Data_TestModels.(char(Cnd))))
         sbjnme = fieldnames(Data_TestModels.(char(Cnd)).(char(Btches(Btc))));  
         for i = 1:length(sbjnme)
             nrkss_pre = sbjnme{i}(2:end)
                 Data_TestModels2.(char(Cnd)).(char(['Subj',num2str(nrkss_pre)])) = Data_TestModels.(char(Cnd)).(char(Btches(Btc))).(char(['P',num2str(nrkss_pre)]));
         end
     end
     
   % re-structure data in order of #of subjects
     Sbjs = fieldnames(Data_TestModels2.(char(Cnd)))
      for i = 1:length(Sbjs)      
         S = fieldnames(Data_TestModels2.(char(Cnd)).(char(Sbjs(i))));
         C = natsortfiles(S);
           for k = 1:numel(C)
               Data_TestModels3.(char(Cnd)).(char(Sbjs(i))).(char(C(k))) = Data_TestModels2.(char(Cnd)).(char(Sbjs(i))).(char(C(k)));
           end
           clearvars S C k
      end
      
         S = fieldnames(Data_TestModels2.(char(Cnd)));
         C = natsortfiles(S);
           for k = 1:numel(C)
               Data_TestModels4.(char(Cnd)).(char(C(k))) = Data_TestModels3.(char(Cnd)).(char(C(k)));
           end
           clearvars S C k
     clearvars -except Data_BaselineModel Data_TestModels4 Cnd Sbjs
     Data_TestModels = Data_TestModels4;
     clearvars Data_TestModels4
     Grps = fieldnames(Data_TestModels.(char(Cnd)).(char(Sbjs(1))));
     Sbjs = fieldnames(Data_TestModels.(char(Cnd)))  ;   
     
  % Remove N2 condition
     for i = 1:length(Sbjs)
         Data_TestModels.(char(Cnd)).(char(Sbjs(i))) = rmfield(Data_TestModels.(char(Cnd)).(char(Sbjs(i))),'N2');
     end
     Grps(1) = [];
     
     
  % Calculate individual correlations
     for i = 1:length(Sbjs)
         for k = 1:30
            Pre_data = Data_BaselineModel.(char(Cnd)).(char(Sbjs(i))).(char(['Cycle',num2str(k)]));
            Pre_data(isnan(Pre_data)) = 0;
            Temp.(char(['Ccle_' num2str(k) '_Baseline'])) = Pre_data;
            clearvars Pre_data
               for Grp = 1:length(Grps)
                  nmsss = fieldnames(Data_TestModels.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))));
                     for l = 1:length(nmsss)
                          Pre_data = Data_TestModels.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(nmsss(l))).(char(['Cycle',num2str(k)]));
                          Pre_data(isnan(Pre_data)) = 0;
                          Temp.(char(['Ccle_' num2str(k) '_' char(Grps(Grp)) '_Iter' num2str(l)])) = Pre_data;
                          [r_pre p_pre] = corrcoef(Temp.(char(['Ccle_' num2str(k) '_Baseline'])),Temp.(char(['Ccle_' num2str(k) '_' char(Grps(Grp)) '_Iter' num2str(l)])));
                          Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Ccle_' num2str(k)])).r_values.(char(['r_Ccle_' num2str(k) '_' char(Grps(Grp)) '_BaselineVSIter' num2str(l)])) = r_pre(2,1);
                          
                          peak_r = r_pre(2,1);
                          z_temp = 0.5*log((1+peak_r)/(1-peak_r));
                          Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Ccle_' num2str(k)])).z_values.(char(['z_Ccle_' num2str(k) '_' char(Grps(Grp)) '_BaselineVSIter' num2str(l)])) = z_temp;
                          z(l,1) = z_temp;
                            clearvars z_temp Pre_data peak_r r_pre
                     end
                       z_mean = nanmean(z);
                       z_CI(1,1) = nanmean(z) - (1.96 * (std(z)/sqrt(length(z))));
                       z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

                    % Transform mean z-value back to r-value   
                        r_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
                        r_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
                        r_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);

                      Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Ccle_' num2str(k)])).Correlation_r_mean = r_final;       
                      Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Ccle_' num2str(k)])).Correlations_r_CI = r_final_CI; 
                            clearvars z_mean z_CI z r_final_CI r_final 
               end
               clearvars Temp Pre_data
         end
     end
     
  % Calculate correlations between nanmean cycle of each iteration and baseline data
     for i = 1:length(Sbjs)
            Pre_data = Data_BaselineModel.(char(Cnd)).(char(Sbjs(i))).nanmean;
            Pre_data(isnan(Pre_data)) = 0;
            Temp.(char(['Nanmean_Baseline'])) = Pre_data;
            clearvars Pre_data
               for Grp = 1:length(Grps)
                  nmsss = fieldnames(Data_TestModels.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))));
                     for l = 1:length(nmsss)
                          Pre_data = Data_TestModels.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(nmsss(l))).nanmean;
                          Pre_data(isnan(Pre_data)) = 0;
                          Temp.(char(['Nanmean_' char(Grps(Grp)) '_Iter' num2str(l)])) = Pre_data;
                          [r_pre p_pre] = corrcoef(Temp.(char(['Nanmean_Baseline'])),Temp.(char(['Nanmean_' char(Grps(Grp)) '_Iter' num2str(l)])));
                          Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).r_values.(char(['r_' char(Grps(Grp)) '_BaselineVSIter' num2str(l)])) = r_pre(2,1);
                          
                          peak_r = r_pre(2,1);
                          z_temp = 0.5*log((1+peak_r)/(1-peak_r));
                          Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).z_values.(char(['z_' char(Grps(Grp)) '_BaselineVSIter' num2str(l)])) = z_temp;
                          z(l,1) = z_temp;
                            clearvars z_temp Pre_data peak_r r_pre
                     end
                       z_mean = nanmean(z);
                       z_CI(1,1) = nanmean(z) - (1.96 * (std(z)/sqrt(length(z))));
                       z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

                    % Transform mean z-value back to r-value   
                        r_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
                        r_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
                        r_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);

                      Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).Correlation_r_mean = r_final;       
                      Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).Correlations_r_CI = r_final_CI; 
                            clearvars z_mean z_CI z r_final_CI r_final 
               end
               clearvars Temp Pre_data
     end     
     
     
  % Calculate individual correlations
     Tlr2 = 1;           
     for i = 1:length(Sbjs)
           for Grp = 1:length(Grps)
               Tlr = 0;
               for k = 1:30
                 for s = 1:10
                    z_values_pre(Tlr+s,1) = Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Ccle_' num2str(k)])).z_values.(char(['z_Ccle_' num2str(k) '_' char(Grps(Grp)) '_BaselineVSIter' num2str(s)]));
                 end      
                 Tlr = length(z_values_pre); 
               end
               Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).AllCycles.z_values = z_values_pre;
               z_values_pre2.(char(Grps(Grp)))(Tlr2:(Tlr2+Tlr-1),1) = z_values_pre;
               clearvars z_values_pre
           end
        Tlr2 = Tlr2+Tlr;
     end
     Robustness_Results_BaselineVSTests_Final.(char(Cnd)).AllSubjects.z_values = z_values_pre2;
     clearvars z_values_pre2 Tlr Tlr2 i k s
     

     for i = 1:length(Sbjs)
        for Grp = 1:length(Grps)
           z = Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).AllCycles.z_values;
           z_mean = nanmean(z);
           z_CI(1,1) = nanmean(z) - (1.96 * (std(z)/sqrt(length(z))));
           z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

            r_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
            r_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
            r_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);

             Robustness_Results_BaselineVSTests_Final.(char(Cnd)).PerSubject.(char(Sbjs(i))).Correlation_r_mean.(char(Grps(Grp))) = r_final;       
             Robustness_Results_BaselineVSTests_Final.(char(Cnd)).PerSubject.(char(Sbjs(i))).Correlations_r_CI.(char(Grps(Grp))) = r_final_CI; 
          clearvars z_mean z_CI z r_final_CI r_final
        end
     end    
     
   % Get z-values of all subjects and iterations per model configuration
     Tlr2 = 1; 
     Tlr = 0;
     for i = 1:length(Sbjs)
           for Grp = 1:length(Grps)
                 for s = 1:10
                    z_values_pre(Tlr+s,1) = Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).z_values.(char(['z_' char(Grps(Grp)) '_BaselineVSIter' num2str(s)]));
                    z_values_pre(Tlr+s,1) = Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).z_values.(char(['z_' char(Grps(Grp)) '_BaselineVSIter' num2str(s)]));
                 end      
               Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).AllCycles_nanmean.z_values_MeanOf10ValuesFirst = mean(z_values_pre);
               z_values_pre2.(char(Grps(Grp)))(Tlr2:(Tlr2+Tlr-1),1) = mean(z_values_pre);
               z_values_pre2.(char(Grps(Grp)))(Tlr2,1) = mean(z_values_pre);
               clearvars z_values_pre
           end
        Tlr = 0;            
        Tlr2 = Tlr2+1;
     end
     Robustness_Results_BaselineVSTests_Final.(char(Cnd)).AllSubjects_nanmean.z_values_MeanOf10ValuesFirst = z_values_pre2;
     clearvars z_values_pre2 Tlr Tlr2 i k s
     

   % Calculate correlation per subject per configuration     
     for i = 1:length(Sbjs)
        for Grp = 1:length(Grps)
           z = Robustness_Results_BaselineVSTests.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).AllCycles_nanmean.z_values;
           z_mean = nanmean(z);
           z_CI(1,1) = nanmean(z) - (1.96 * (std(z)/sqrt(length(z))));
           z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

            r_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
            r_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
            r_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);

             Robustness_Results_BaselineVSTests_Final.(char(Cnd)).PerSubject_nanmean.(char(Sbjs(i))).Correlation_r_mean.(char(Grps(Grp))) = r_final;       
             Robustness_Results_BaselineVSTests_Final.(char(Cnd)).PerSubject_nanmean.(char(Sbjs(i))).Correlations_r_CI.(char(Grps(Grp))) = r_final_CI; 
          clearvars z_mean z_CI z r_final_CI r_final
        end
     end     
     
     
     for Grp = 1:length(Grps)
         z = Robustness_Results_BaselineVSTests_Final.(char(Cnd)).AllSubjects.z_values.(char(Grps(Grp)));
         z_mean = nanmean(z);
         z_CI(1,1) = nanmean(z) - (1.96 * (std(z)/sqrt(length(z))));
         z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

          r_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
          r_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
          r_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);

           Robustness_Results_BaselineVSTests_Final.(char(Cnd)).AllSubjects.Correlation_r_mean.(char(Grps(Grp))) = r_final;       
           Robustness_Results_BaselineVSTests_Final.(char(Cnd)).AllSubjects.Correlations_r_CI.(char(Grps(Grp))) = r_final_CI; 
         clearvars z_mean z_CI z r_final_CI r_final
     end
     
   % Calculate single correlation value (mean of all subjects) per configuration     
     for Grp = 1:length(Grps)
         z = Robustness_Results_BaselineVSTests_Final.(char(Cnd)).AllSubjects_nanmean.z_values_MeanOf10ValuesFirst.(char(Grps(Grp)));
         z_mean = nanmean(z);
         z_CI(1,1) = nanmean(z) - (1.96 * (std(z)/sqrt(length(z))));
         z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

          r_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
          r_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
          r_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);

           Robustness_Results_BaselineVSTests_Final.(char(Cnd)).AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp))) = r_final;       
           Robustness_Results_BaselineVSTests_Final.(char(Cnd)).AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst.(char(Grps(Grp))) = r_final_CI; 
         clearvars z_mean z_CI z r_final_CI r_final
     end     
     
  %% Run these to get final figures saved as "ParticipantNrTest_V2_gait_nanmean_subjects and _group"
  % Plot results - group means VS baseline    
     NrGroups = length(Grps);
     figure
     subplot(1,2,1)
      hold on     
       ylabel('r');
       xlabel('');
       set(gcf,'Color','w');          
         for Grp = 1:NrGroups-1
            h1 = errorbar(Grp,Robustness_Results_BaselineVSTests_Final.Cycling.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1),Robustness_Results_BaselineVSTests_Final.Cycling.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1)-Robustness_Results_BaselineVSTests_Final.Cycling.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1),Robustness_Results_BaselineVSTests_Final.Cycling.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1)-Robustness_Results_BaselineVSTests_Final.Cycling.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1),'-o')
            set(h1,'MarkerSize',2,'LineWidth',0.5,'Color','r','MarkerFaceColor','k','MarkerEdgeColor','k')
         end
         for Grp = 1:NrGroups-1
                YVs(Grp,1) = Robustness_Results_BaselineVSTests_Final.Cycling.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1);
         end                
            h1 = plot([1:1:length(Grps)-1],YVs,'-x')
            set(h1,'MarkerSize',8,'LineWidth',0.5,'Color','k')
           xticks([1:1:NrGroups-1])
           xticklabels([])
           set(gca,'FontSize',16) 
            title('Pedalling','FontSize',12)           
            ylim([0 1])            
     subplot(2,1,2)  
     hold on
       ylabel('r');
       xlabel('# of participants');
       set(gcf,'Color','w');      
         for Grp = 1:NrGroups-1
            h2 = errorbar(Grp,Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1),Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1)-Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1),Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1)-Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1),'-o')
            set(h2,'MarkerSize',5,'LineWidth',0.5,'Color','k')
         end 
         for Grp = 1:NrGroups-1
                YVs2(Grp,1) = Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1);
         end                
            h2 = plot([1:1:length(Grps)-1],YVs2,'--o')
            set(h2,'MarkerSize',8,'LineWidth',0.5,'Color','k')
           xticks([1:1:NrGroups-1])
           xticklabels([6:4:74])
           set(gca,'FontSize',16) 
            title('Walking','FontSize',12)           
            ylim([0 1])   
            set(gcf,'Position',[350 65 850 700])
            cd(strcat('C:\Users\Jeroen\Nextcloud\Projects\Machine_Learning\Matlab\Results\Figures\Final_1\'));
            print(figure(gcf),'ParticipantNrTest_V3_option4_Final_nanmean_group_VS_baseline','-djpeg','-r0');
            saveas(figure(gcf),strcat('ParticipantNrTest_V3_option4_Final_nanmean_group_VS_baseline','.fig'));
            
            
 %%
 %%%%%%%%%%%%%%%%%%
 %%% Figure 3
 %%%%%%%%%%%%%%%%%%      
   NrGroups = length(Grps);
     figure
     subplot(1,2,1)
      hold on     
       ylabel('r');
       xlabel('');
       set(gcf,'Color','w');          
         for Grp = 1:NrGroups-1
                YVs(Grp,1) = Robustness_Results_BaselineVSTests_Final.Cycling.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1);
                YV_ers(Grp,:) = Robustness_Results_BaselineVSTests_Final.Cycling.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,:);
         end    
         XVs = [1:1:length(Grps)-1]';
         XVs(:,1) = XVs - 0.2;
         XVs(:,2) = XVs + 0.4;
         for i = 1:NrGroups-1
            h1(i) = patch([XVs(i,1) XVs(i,2) XVs(i,2) XVs(i,1)],[YV_ers(i,1) YV_ers(i,1) YV_ers(i,2) YV_ers(i,2)],[.9 .9 .9],'linestyle','none');
            plot(i,YVs(i,1),'o','MarkerFaceColor','w','MarkerEdgeColor','w','MarkerSize',2)
         end 
         set(h1,'FaceColor','k','EdgeColor','k')
       xlabel('# of participants');
           xticks([1:1:NrGroups-1])
           xticklabels([6 {'' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''} 74])
           set(gca,'FontSize',14) 
            title('Pedalling','FontSize',12)           
            ylim([0 1])            
     subplot(1,2,2)
      hold on          
         for Grp = 1:NrGroups-1
                YVs2(Grp,1) = Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1);
                YV_ers2(Grp,:) = Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,:);
         end           
         for i = 1:NrGroups-1
            h2(i) = patch([XVs(i,1) XVs(i,2) XVs(i,2) XVs(i,1)],[YV_ers2(i,1) YV_ers2(i,1) YV_ers2(i,2) YV_ers2(i,2)],[.9 .9 .9],'linestyle','none');
            plot(i,YVs(i,1),'o','MarkerFaceColor','w','MarkerEdgeColor','w','MarkerSize',2)
         end         
         set(h2,'FaceColor','k','EdgeColor','k')
       xlabel('# of participants');
           xticks([1:1:NrGroups-1])
           xticklabels([6 {'' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''} 74])
           set(gca,'FontSize',14) 
            title('Walking','FontSize',12)           
            ylim([0 1])   
            set(gcf,'Position',[350 165 920 350])
            cd(strcat('C:\Users\Jeroen\Nextcloud\Projects\Machine_Learning\Matlab\Results\Figures\Final_2\'));
            print(figure(gcf),'ParticipantNrTest_V4_Final_nanmean_group_VS_baseline','-dtiffn','-r0');
            saveas(figure(gcf),strcat('ParticipantNrTest_V4_Final_nanmean_group_VS_baseline','.fig'));
                        
            
 %%
 %%%%%%%%%%%%%%%%%%
 %%% Figure 3
 %%%%%%%%%%%%%%%%%%      
        Chosen1s = randi(78,1);
        ChosenItr = randi(10,1);
         Vctr_Baseline = Data_BaselineModel.Cycling.(char(Sbjs(Chosen1s))).nanmean;
         Vctr_A = Data_TestModels.Cycling.(char(Sbjs(Chosen1s))).N6.(char(['S' num2str(ChosenItr)])).nanmean;
         Vctr_B = Data_TestModels.Cycling.(char(Sbjs(Chosen1s))).N30.(char(['S' num2str(ChosenItr)])).nanmean;
         Vctr_C = Data_TestModels.Cycling.(char(Sbjs(Chosen1s))).N50.(char(['S' num2str(ChosenItr)])).nanmean;      
         
   NrGroups = length(Grps);
     figure
      hold on     
       ylabel('Relevance score');
       xlabel('');
       set(gcf,'Color','w');         
         plot(Vctr_Baseline,'k','LineWidth',1.5)
         plot(Vctr_A,'r','LineWidth',0.5,'LineStyle','-')
         plot(Vctr_B,'b','LineWidth',0.5,'LineStyle','-')
         plot(Vctr_C,'g','LineWidth',0.5,'LineStyle','-')      
            VrtL = [-0.02:1:1.02];
            for m = 1:8
                VrtLloc = zeros(length(VrtL),1);
                VrtLloc(:,:) = 200*m;
                plot(VrtLloc,VrtL,'k');   
            end
       xlabel('');
           xticks([1:1:NrGroups-1])
           xticklabels([])
           set(gca,'FontSize',14) 
            ylim([0 1])   
            set(gcf,'Position',[350 165 920 350])
            cd(strcat('C:\Users\Jeroen\Nextcloud\Projects\Machine_Learning\Matlab\Results\Figures\Final_2\'));
            print(figure(gcf),'ParticipantNrTest_RelevanceScores','-dtiffn','-r0');
            saveas(figure(gcf),strcat('ParticipantNrTest_RelevanceScores','.fig'));            
          


%% Testing what correlations we would get due to "random chance"
   % i.e. when comparing signatures with signature from next subject
  % Calculate correlations between nanmean cycle of each iteration and baseline data
     for i = 1:length(Sbjs)
         if i == length(Sbjs)
            Pre_data = Data_BaselineModel.(char(Cnd)).(char(Sbjs(1))).nanmean;             
         else
            Pre_data = Data_BaselineModel.(char(Cnd)).(char(Sbjs(i+1))).nanmean;
         end
            Pre_data(isnan(Pre_data)) = 0;
            Temp.(char(['Nanmean_Baseline'])) = Pre_data;
            clearvars Pre_data
               for Grp = 1:length(Grps)
                  nmsss = fieldnames(Data_TestModels.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))));
                     for l = 1:length(nmsss)
                          Pre_data = Data_TestModels.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(nmsss(l))).nanmean;
                          Pre_data(isnan(Pre_data)) = 0;
                          Temp.(char(['Nanmean_' char(Grps(Grp)) '_Iter' num2str(l)])) = Pre_data;
                          [r_pre p_pre] = corrcoef(Temp.(char(['Nanmean_Baseline'])),Temp.(char(['Nanmean_' char(Grps(Grp)) '_Iter' num2str(l)])));
                          Robustness_Results_BaselineVSTests_WrongSubject.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).r_values.(char(['r_' char(Grps(Grp)) '_BaselineVSIter' num2str(l) 'iplus1'])) = r_pre(2,1);
                          
                          peak_r = r_pre(2,1);
                          z_temp = 0.5*log((1+peak_r)/(1-peak_r));
                          Robustness_Results_BaselineVSTests_WrongSubject.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).z_values.(char(['z_' char(Grps(Grp)) '_BaselineVSIter' num2str(l) 'iplus1'])) = z_temp;
                          z(l,1) = z_temp;
                            clearvars z_temp Pre_data peak_r r_pre
                     end
                       z_mean = nanmean(z);
                       z_CI(1,1) = nanmean(z) - (1.96 * (std(z)/sqrt(length(z))));
                       z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

                    % Transform mean z-value back to r-value   
                        r_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
                        r_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
                        r_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);

                      Robustness_Results_BaselineVSTests_WrongSubject.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).Correlation_r_mean_iplus1 = r_final;       
                      Robustness_Results_BaselineVSTests_WrongSubject.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).Correlations_r_CI_iplus1 = r_final_CI; 
                            clearvars z_mean z_CI z r_final_CI r_final 
               end
               clearvars Temp Pre_data
     end     
     
   % Get z-values of all subjects and iterations per model configuration
     Tlr2 = 1; 
     Tlr = 0;
     for i = 1:length(Sbjs)
           for Grp = 1:length(Grps)
                 for s = 1:10
%                     z_values_pre(Tlr+s,1) = Robustness_Results_BaselineVSTests_WrongSubject.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).z_values.(char(['z_' char(Grps(Grp)) '_BaselineVSIter' num2str(s)]));
                    z_values_pre(Tlr+s,1) = Robustness_Results_BaselineVSTests_WrongSubject.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).(char(['Nanmean'])).z_values.(char(['z_' char(Grps(Grp)) '_BaselineVSIter' num2str(s) 'iplus1']));
                 end      
               Robustness_Results_BaselineVSTests_WrongSubject.(char(Cnd)).(char(Sbjs(i))).(char(Grps(Grp))).AllCycles_nanmean.z_values_MeanOf10ValuesFirst_iplus1 = mean(z_values_pre);
%                z_values_pre2.(char(Grps(Grp)))(Tlr2:(Tlr2+Tlr-1),1) = mean(z_values_pre);
               z_values_pre2.(char(Grps(Grp)))(Tlr2,1) = mean(z_values_pre);
               clearvars z_values_pre
           end
        Tlr = 0;            
        Tlr2 = Tlr2+1;
     end
     Robustness_Results_BaselineVSTests_WrongSubject_Final.(char(Cnd)).AllSubjects_nanmean.z_values_MeanOf10ValuesFirst_iplus1 = z_values_pre2;
     clearvars z_values_pre2 Tlr Tlr2 i k s
     

   % Calculate single correlation value (mean of all subjects) per configuration     
     for Grp = 1:length(Grps)
         z = Robustness_Results_BaselineVSTests_WrongSubject_Final.(char(Cnd)).AllSubjects_nanmean.z_values_MeanOf10ValuesFirst_iplus1.(char(Grps(Grp)));
         z_mean = nanmean(z);
         z_CI(1,1) = nanmean(z) - (1.96 * (std(z)/sqrt(length(z))));
         z_CI(1,2) = nanmean(z) + (1.96 * (nanstd(z)/sqrt(length(z))));                 

          r_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
          r_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
          r_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);

           Robustness_Results_BaselineVSTests_WrongSubject_Final.(char(Cnd)).AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst_iplus1.(char(Grps(Grp))) = r_final;       
           Robustness_Results_BaselineVSTests_WrongSubject_Final.(char(Cnd)).AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst_iplus1.(char(Grps(Grp))) = r_final_CI; 
         clearvars z_mean z_CI z r_final_CI r_final
     end      
     
     
  % Plot results - group means VS baseline    
     NrGroups = length(Grps);
     figure
%      subplot(2,1,1)
      hold on     
       ylabel('r');
       xlabel('');
       set(gcf,'Color','w');          
         for Grp = 1:NrGroups-1
            h1 = errorbar(Grp,Robustness_Results_BaselineVSTests_WrongSubject_Final.Cycling.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst_iplus1.(char(Grps(Grp)))(:,1),Robustness_Results_BaselineVSTests_WrongSubject_Final.Cycling.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst_iplus1.(char(Grps(Grp)))(:,1)-Robustness_Results_BaselineVSTests_WrongSubject_Final.Cycling.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst_iplus1.(char(Grps(Grp)))(:,1),Robustness_Results_BaselineVSTests_WrongSubject_Final.Cycling.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst_iplus1.(char(Grps(Grp)))(:,1)-Robustness_Results_BaselineVSTests_WrongSubject_Final.Cycling.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst_iplus1.(char(Grps(Grp)))(:,1),'-x')
            set(h1,'MarkerSize',5,'LineWidth',0.5,'Color','k')
         end
         for Grp = 1:NrGroups-1
                YVs(Grp,1) = Robustness_Results_BaselineVSTests_WrongSubject_Final.Cycling.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst_iplus1.(char(Grps(Grp)))(:,1);
         end                
            h1 = plot([1:1:length(Grps)-1],YVs,'-x')
            set(h1,'MarkerSize',8,'LineWidth',0.5,'Color','k')
%            xticks([1:1:NrGroups-1])
%            xticklabels([])
%            set(gca,'FontSize',16) 
%             title('Pedalling','FontSize',12)           
%             ylim([0 1])            
%      subplot(2,1,2)  
%      hold on
%        ylabel('r');
       xlabel('# of participants');
%        set(gcf,'Color','w');      
%          for Grp = 1:NrGroups-1
%             h2 = errorbar(Grp,Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1),Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1)-Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1),Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1)-Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlations_r_CI_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1),'-o')
%             set(h2,'MarkerSize',5,'LineWidth',0.5,'Color','k')
%          end 
         for Grp = 1:NrGroups-1
                YVs2(Grp,1) = Robustness_Results_BaselineVSTests_Final.Gait.AllSubjects_nanmean.Correlation_r_mean_MeanOf10ValuesFirst.(char(Grps(Grp)))(:,1);
         end                
            h2 = plot([1:1:length(Grps)-1],YVs2,'--o')
            set(h2,'MarkerSize',8,'LineWidth',0.5,'Color','k')
           xticks([1:1:NrGroups-1])
           xticklabels([6:4:74])
           set(gca,'FontSize',16) 
            title('Walking','FontSize',12)           
            ylim([0 1])   
            set(gcf,'Position',[350 165 850 400])
            cd(strcat('C:\Users\Jeroen\Nextcloud\Projects\Machine_Learning\Matlab\Results\Figures\Final_1\'));
            print(figure(gcf),'ParticipantNrTest_WrongSubject_option4_Final_nanmean_group_VS_baseline','-djpeg','-r0');
            saveas(figure(gcf),strcat('ParticipantNrTest_WrongSubject_option4_Final_nanmean_group_VS_baseline','.fig'));
                 