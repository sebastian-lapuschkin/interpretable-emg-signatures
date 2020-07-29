clear
load('Data_Walking_Baseline_Day1.mat')

Feature_Complete = Feature;
Target_Subject_Complete = Target_Subject;

clearvars Feature Target_Subject

for k=1:size(Target_Subject_Complete,2)
    
    for m=2:4:size(Target_Subject_Complete,2)
        
        for n=1:10
            
            Feature_Temp = Feature_Complete;

            Target_Subject_Temp = Target_Subject_Complete;
            Target_Subject_Temp(:,[1 k]) = Target_Subject_Temp(:,[k 1]);
            
            temp_list = 1:size(Target_Subject_Temp,2);
            temp_list(1) = [];
            temp_list = temp_list(randperm(length(temp_list)));
            
            [temp_row, ~] = find(Target_Subject_Temp(:,1) == 1 | Target_Subject_Temp(:,temp_list((1:m-1))) == 1);
            temp_row_uni = unique(temp_row);
            
            Feature = Feature_Temp(temp_row_uni,:,:);
            Target_Subject = Target_Subject_Temp(temp_row_uni,:);
            
            save(['Robustness\Walking\Data_Walking_Baseline_Day1_P' num2str(k),'_N', num2str(m),'_S', num2str(n),'.mat'],'Feature','Feature_EMG_Label','Target_Subject')
            
            clearvars temp_list Feature Target_Subject Feature_Temp Target_Subject_Temp temp_row temp_row_uni
            
        end
        
    end
    
end