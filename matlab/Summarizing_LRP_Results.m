clear

% select path in python/output
cd(uigetdir())

% save selected path as 'global_pfad'
global_path = pwd;

% identify content of selected folder
global_files = dir(global_path);
% only those that are directories
dirFlags = [global_files.isdir];
% list of folders in selected path
global_folders = global_files(dirFlags);

% loop over those folders
for o=3:size(global_folders,1)
      
    clearvars -except o global_path global_folders 
    
    % print progress
    fprintf('progress: %i / %i \n',o,size(global_folders,1))
    
    if not(strcmp({global_folders(o).name}, 'Robustness'))

        % change to folder 'o'
        cd(strcat(global_path,'\',global_folders(o).name))

        temp_files = dir(strcat(global_path,'\',global_folders(o).name));
        if any(strcmp({temp_files.name}, 'data.mat'))

            % load data
            Feature = load('data.mat');
            Splits = load('splits.mat');
            Targets = load('targets.mat');

            % transform target represenatation
            Targets_Subject = zeros(size(Targets.Y,1),1);
            for k=1:size(Targets.Y,1)
                clearvars imax
                [~,imax] = max(Targets.Y(k,:));
                Targets_Subject(k,1) = imax;
            end

            clearvars Targets imax k

            % determine the number of splits (folds of the cross-validation)
            splitAnz = size(Splits.S,1);

            % initialize variables
            Targets_Subject_Split = cell(1,splitAnz);
            Feature_EMG_Split = cell(1,splitAnz);

            % arrange targets und features per split
            for l=1:splitAnz  
                for k=1:size(Splits.S,2) 
                    Targets_Subject_Split{l}(k,1) = Targets_Subject(double(Splits.S(l,k)+1));
                    Feature_EMG_Split{l}(k,:,:) = Feature.X(double(Splits.S(l,k)+1),:,:);
                end
            end

            clearvars Feature Splits split_anz l k

        elseif any(strcmp({temp_files.name}, 'data_test.mat'))

            % load data
            Feature = load('data_test.mat');
            Targets = load('targets_test.mat');

            % transform target represenatation
            Targets_Subject = zeros(size(Targets.Y,1),1);
            for k=1:size(Targets.Y,1)
                clearvars imax
                [~,imax] = max(Targets.Y(k,:));
                Targets_Subject(k,1) = imax;
            end

            clearvars Targets imax k

            % determine the number of splits (folds of the cross-validation)
            splitAnz = 1;

            % initialize variables
            Targets_Subject_Split = cell(1,splitAnz);
            Feature_EMG_Split = cell(1,splitAnz);

            Targets_Subject_Split{1}(:,1) = Targets_Subject;
            Feature_EMG_Split{1}(:,:,:) = Feature.X;

            clearvars Feature Splits split_anz

        end

        clear temp_files

        % change path to folder of used models
        cd('Subject/EMG_AV')
        model_path = pwd;

        % identify content of selected folder
        model_files = dir(model_path);
        % only those that are directories
        dirFlags = [model_files.isdir];
        % list of folders in selected path
        model_folders = model_files(dirFlags);

        % loop over those models
        for l=3:size(model_folders,1)

            clearvars -except l model_path model_folders o global_path global_folders Targets_Subject_Split Feature_EMG_Split Targets_Subject

            % Identify Variables by selected folder
            Feature_Splits = Feature_EMG_Split;

            RpredAct_Output = cell(1,max(Targets_Subject));
            %RpredAct_flat_Output = cell(1,max(Targets_Subject));
            %RpredAct_zb_Output = cell(1,max(Targets_Subject));
            %RpredDom_Output = cell(1,max(Targets_Subject));
            %RpredDom_flat_Output = cell(1,max(Targets_Subject));
            %RpredDom_zb_Output = cell(1,max(Targets_Subject));
            Ypred_Output = cell(1,max(Targets_Subject));
            Yact_Output = cell(1,max(Targets_Subject));
            Feature_Output = cell(1,max(Targets_Subject));
            Subjects_Output = cell(1,max(Targets_Subject));

            cd(strcat(model_path,'\',model_folders(l).name))

            % identify content of selected folder
            split_files = dir(pwd);
            % only those that are directories
            dirFlags = [split_files.isdir];
            % list of folders in selected path
            split_folders = split_files(dirFlags);        

            % loop over those splits        
            for s=3:size(split_folders,1)

                clearvars -except s split_path split_folders l model_path model_folders o global_path global_folders Targets_Subject_Split Feature_EMG_Split Feature_Splits Targets_Subject ...
                    RpredAct_Output RpredAct_flat_Output RpredAct_zb_Output RpredDom_Output RpredDom_flat_Output RpredDom_zb_Output Ypred_Output Yact_Output Feature_Output                

                % Change to model
                cd(strcat(model_path,'\',model_folders(l).name,'\',split_folders(s).name))

                % load output file
                Outputs = load('outputs.mat');

                split = s-2;

                Feature_Splits_Temp = Feature_Splits{split};

                % loop over outputs & arrange input and heatmaps
                for i=1:size(Outputs.R_pred_act_epsilon,1)

                    clearvars -except i s split_path split_folders Outputs split Feature_Splits_Temp l model_path model_folders o global_path global_folders Targets_Subject_Split Feature_EMG_Split Feature_Splits Targets_Subject ...
                        RpredAct_Output RpredAct_flat_Output RpredAct_zb_Output RpredDom_Output RpredDom_flat_Output RpredDom_zb_Output Ypred_Output Yact_Output Feature_Output

                    x(:,:) = Feature_Splits_Temp(i,:,:);

                    yt = Targets_Subject_Split{split}(i);
                    [~,yp] = max(Outputs.y_pred(i,:));

                    %fprintf('True Class:      %d\n', yt);
                    %fprintf('Predicted Class: %d\n\n', yp);

                    RpredAct_Temp(:,:) = Outputs.R_pred_act_epsilon(i,:,:);
                    %RpredAct_flat_Temp(:,:) = Outputs.R_pred_act_epsilon_flat(i,:,:);
                    %RpredAct_zb_Temp(:,:) = Outputs.R_pred_act_epsilon_zb(i,:,:);
                    %RpredDom_Temp(:,:) = Outputs.R_pred_dom_epsilon(i,:,:);
                    %RpredDom_flat_Temp(:,:) = Outputs.R_pred_dom_epsilon_flat(i,:,:);
                    %RpredDom_zb_Temp(:,:) = Outputs.R_pred_dom_epsilon_zb(i,:,:);
                    Ypred_Temp(:,:) = Outputs.y_pred(i,:,:);
                    Yact_Temp(:,:) = yt;

                    RpredAct_Output{yt}(end+1,:) = reshape(RpredAct_Temp,[],1);
                    %RpredAct_flat_Output{yt}(end+1,:) = reshape(RpredAct_flat_Temp,[],1);
                    %RpredAct_zb_Output{yt}(end+1,:) = reshape(RpredAct_zb_Temp,[],1);
                    %RpredDom_Output{yt}(end+1,:) = reshape(RpredDom_Temp,[],1);
                    %RpredDom_flat_Output{yt}(end+1,:) = reshape(RpredDom_flat_Temp,[],1);
                    %RpredDom_zb_Output{yt}(end+1,:) = reshape(RpredDom_zb_Temp,[],1);
                    Ypred_Output{yt}(end+1,:) = reshape(Ypred_Temp,[],1);
                    Yact_Output{yt}(end+1,:) = reshape(Yact_Temp,[],1);
                    Feature_Output{yt}(end+1,:) = reshape(x,[],1);

                end

            end

            [Name,~] = strsplit(strcat(model_path,'\',model_folders(l).name),'\');

            savefile = strcat(global_path,'\',cell2mat(strcat(Name(end-3),'_',Name(end-2),'_',Name(end-1),'_',Name(end))),'.mat');
            save(savefile, 'Feature_Output', 'RpredAct_Output', 'Ypred_Output', 'Yact_Output');

        end
        
    else
        
    end
    
    cd(global_path)

end

