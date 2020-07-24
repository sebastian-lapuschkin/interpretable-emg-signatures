%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Script used to determine individual muscle activation signatures
%%%%%   By Dr Jeroen Aeles, Dr Fabian Horst, Dr Sebastian Lapuschkin, Dr Lilian Lacourpaille, Dr François Hug
%%%%%   Last edited on 23 July 2020
%%%%%   The script uses the input variables from XXX
%%%%%   The figures in the script refer to the paper below
%%%%%   XXX
%%%%%
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

clear all
clc

 main_dir = 'C:\';

%% Prepare data structures 
cd(main_dir);
liste = dir(fullfile(main_dir,'*.mat'));
files = {liste.name};
mod_sel = [566];

  %% Organise data
    for i=mod_sel
      load(files{i})    
      Rpred_Output = RpredAct_Output;
        for k=1:size(Rpred_Output,2)  
            if isempty(Rpred_Output{k}) == 1
            else
                for m=1:size(Rpred_Output{k},1)
                    Rpred_Norm_Output{k}(m,:) = Rpred_Output{k}(m,:) / Ypred_Output{k}(m,k);
                end

                Rpred_Output_Mean{i}(k,:) = nanmean(Rpred_Output{k});
                Rpred_Output_SD{i}(k,:) = nanstd(Rpred_Output{k});

                Feature_Output_Mean{i}(k,:) = nanmean(Feature_Output{k});
                Feature_Output_SD{i}(k,:) = nanstd(Feature_Output{k});
            end
        end    
    end


%% Create methods example figure
 %%%%%%%%%%%%%%%%%%
 %%% Figure 1
 %%%%%%%%%%%%%%%%%%
figure(1);
sub_sel = 1
muscle_nms = {'VL','RF','VM','GL','GM','SOL','TA','BF'};
Level_H = 0.20;      % highlight above this relevance threshold on plots
    for i=sub_sel    % subject   
        idx=1;
        for k= 4    % cycle

            files_parts = strsplit(files{i},'_');
            files_parts_classifier = strsplit(string(files_parts(end)),'.mat');

            Rpred_Temp = Rpred_Output{i}(k,:);
            x = Feature_Output{i}(k,:);        

            Rpred_Temp = Rpred_Temp';
            Rpred_Temp = Rpred_Temp / max(abs(Rpred_Temp));    % normalise to max (can be - or +) value
            x = x';
            t(1:size(Rpred_Temp,1),1) = (1:size(Rpred_Temp,1));

            filename = strcat(path,'_',files_parts_classifier(1));

            cmap = colormap(jet);
            cmin = -1;
            cmax = +1;
            c = round(1+(size(cmap,1)-1)*(Rpred_Temp - cmin)/(cmax-cmin));
            c(isnan(c)) = (size(cmap,1)/2);

            VrtL = [-1:1:102];

            subplot(5,1,idx);
            set(gcf,'Color','w');
            PlotPos = get(gca,'Position') ;
            LftCorner = [(PlotPos(1)/5) PlotPos(2)];
                PlotWidths = PlotPos(3)/8;
                PlotHeights = PlotPos(4)/3  ;

            for m=1:8
                plot(t((m-1)*200+1:(m)*200),(x((m-1)*200+1:(m)*200)).*100,'linestyle','none');
                for l=(m-1)*200+1:(((m-1)*200)+size(x((m-1)*200+1:(m)*200),1)-1)
                    line(t(l:l+1),(x(l:l+1)).*100,'color',cmap(c(l),:),'lineWidth',2.5)
                end            
                hold on

    %           Add vertical lines between muscles and label muscle columns 
                xticks([0:50:1600])
                xticklabels('')

                VrtLloc = zeros(length(VrtL),1);
                VrtLloc(:,:) = 200*m;
                plot(VrtLloc,VrtL,'k');

                    if m == 1
                     ylabel('Relative EMG amplitude','FontSize',16);
                     yticks([0:50:100]);
                     xticklabels('') ;
                     a_tmp = get(gca,'YTickLabel');
                     set(gca,'YTickLabel',a_tmp,'fontsize',16);
                    end
            end

    %      Create x-axis ticks at 25,50,75% of the cycle and remove top axis ticks 
            hold off
            ax_org = gca;
                box off
                ax1 = gca;
                ax2 = axes('Position', get(ax1, 'Position'),...
                           'Color','None','XColor','none','YColor','k',...
                           'XAxisLocation','top', 'XTick', [],... 
                           'YAxisLocation','right', 'YTick', []);
                 linkaxes([ax1, ax2])                  

            xlim([0 1600]);
            ylim([0 100]);
            hold on
                HrzL = [0 0]; 
                plot([0 1601],HrzL,'k');      
            ClrbrLoc = [(PlotPos(1)+(1.02*PlotPos(3))) (PlotPos(2)) 0.02 PlotPos(4)] ;
            Cb = colorbar('Position',ClrbrLoc);
            Cb.TickLabels = {-1;0;1};         
            clearvars cmap cmin cmax c x t Rpred_Temp files_parts_class_title
        end
    end


% Plot with [0 1] but same colormap as [-1 1] (<0 black)
for i=sub_sel    % subject
    idx=2;
    for k= 4    % cycle
        
        files_parts = strsplit(files{i},'_');
        files_parts_classifier = strsplit(string(files_parts(end)),'.mat');

        Rpred_Temp = Rpred_Output{i}(k,:);
        x = Feature_Output{i}(k,:);        

        Rpred_Temp = Rpred_Temp';
        Rpred_Temp = Rpred_Temp / max(abs(Rpred_Temp));    % normalise to max (can be - or +) value
        x = x';
        t(1:size(Rpred_Temp,1),1) = (1:size(Rpred_Temp,1));

        filename = strcat(path,'_',files_parts_classifier(1));

        cmap = colormap(jet);
        cmin = -1;
        cmax = +1;
        c = round(1+(size(cmap,1)-1)*(Rpred_Temp - cmin)/(cmax-cmin));
        c(isnan(c)) = (size(cmap,1)/2);
        VrtL = [-1:1:102];

        subplot(5,1,idx);
        PlotPos = get(gca,'Position') ;
        LftCorner = [(PlotPos(1)/5) PlotPos(2)];
            PlotWidths = PlotPos(3)/8;
            PlotHeights = PlotPos(4)/3  ;
        
        for m=1:8
            plot(t((m-1)*200+1:(m)*200),(x((m-1)*200+1:(m)*200)).*100,'linestyle','none');
            for l=(m-1)*200+1:(((m-1)*200)+size(x((m-1)*200+1:(m)*200),1)-1)
                line(t(l:l+1),(x(l:l+1)).*100,'color',cmap(c(l),:),'lineWidth',2.5)
            end            
            hold on           
            
%           Add vertical lines between muscles and label muscle columns 
            xticks([0:50:1600])
            xticklabels('')
            
            VrtLloc = zeros(length(VrtL),1);
            VrtLloc(:,:) = 200*m;
            plot(VrtLloc,VrtL,'k');
                if m == 1
                 yticks([0:50:100]);
                 xticklabels('') ;
                 a_tmp = get(gca,'YTickLabel');
                 set(gca,'YTickLabel',a_tmp,'fontsize',16);
                end
        end
        
         % Calculate areas with relevance score <> a threshold and color
         % black to highlight high (both + an -) relevance scores
            ThrshHld = 0;
            BelowThrsH = find(Rpred_Temp < ThrshHld);
            ThrsGrps = find(diff(BelowThrsH)>1);
            ThrsExLoc = BelowThrsH(ThrsGrps);
            ThrsExLoc2 = BelowThrsH(ThrsGrps+1);

            Thrsbars = zeros((length(ThrsGrps)+1)*2,1);
            Thrsbars(1,1) = BelowThrsH(1,1);
            for tlr = 1:length(ThrsGrps)
                Thrsbars(tlr*2) = ThrsExLoc(tlr);
            end
            for tlr = 1:length(ThrsGrps)
                Thrsbars((tlr*2)+1) = ThrsExLoc2(tlr);
            end
            Thrsbars(end,1) = BelowThrsH(end,1); 
            
            for tlr=1:(length(Thrsbars)/2)
                plot(t((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr)))),(x((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr))))).*100,'color','k','lineWidth',2.5)       % color black 
            end  

     % Create x-axis ticks at 25,50,75% of the cycle and remove top axis ticks
        hold off
        ax_org = gca;
            box off
            ax1 = gca;
            ax2 = axes('Position', get(ax1, 'Position'),...
                       'Color','None','XColor','none','YColor','k',...
                       'XAxisLocation','top', 'XTick', [],... 
                       'YAxisLocation','right', 'YTick', []);
             linkaxes([ax1, ax2])                  
        
        xlim([0 1600]);
        ylim([0 100]);
        hold on
            HrzL = [0 0]; 
            plot([0 1601],HrzL,'k');
        ClrbrLoc = [(PlotPos(1)+(1.02*PlotPos(3))) (PlotPos(2)) 0.02 PlotPos(4)] ;
        Cb = colorbar('Position',ClrbrLoc);
        Cb.TickLabels = {-1;0;1};
        clearvars cmap cmin cmax c x t Rpred_Temp files_parts_class_title
    end
end

 % remove all negative relevance values (make NaN) & normalise   
    Rpred_Output_pre = RpredAct_Output;
  
    for k=1:size(Rpred_Output_pre,2)  
        if isempty(Rpred_Output{k}) == 1
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

for i=sub_sel    
    idx=3;
    for k= 1:30
        hold on
                
        Rpred_Temp = Rpred_Output{i}(k,:);
        x = Feature_Output{i}(k,:);

        Rpred_Temp = Rpred_Temp';
        x = x';
        t(1:size(Rpred_Temp,1),1) = (1:size(Rpred_Temp,1));

        VrtL = [-1:1:102];

        subplot(5,1,idx);
        plot(Rpred_Temp,'k');
            
        AboveThrs = find(Rpred_Temp>0.2);
        Xuse = zeros(length(t),1);
        Xuse(Xuse==0) = NaN;
        Xuse(AboveThrs,1) = AboveThrs     ;   
        plot(Xuse,Rpred_Temp,'b');
        
        for m=1:8
            hold on                
%           Add vertical lines between muscles and label muscle columns 
            xticks([0:50:1600])
            xticklabels('')
            
            VrtLloc = zeros(length(VrtL),1);
            VrtLloc(:,:) = 200*m;
            plot(VrtLloc,VrtL,'k');
        end
         yticks([0:0.5:1]);
         xticklabels('') ;
         HrzL = [0.2 0.2]; 
         plot([0 1601],HrzL,'r');               
         ylabel('Relevance')                 
         a_tmp = get(gca,'YTickLabel');
         set(gca,'YTickLabel',a_tmp,'fontsize',16);                
    end

     % Create x-axis ticks at 25,50,75% of the cycle and remove top axis ticks
        ax_org = gca;
            box off
            ax1 = gca;
            ax2 = axes('Position', get(ax1, 'Position'),...
                       'Color','None','XColor','none','YColor','k',...
                       'XAxisLocation','top', 'XTick', [],... 
                       'YAxisLocation','right', 'YTick', []);
             linkaxes([ax1, ax2])                  
        
        xlim([0 1600]);
        ylim([0 1]);
        hold on
            HrzL = [0 0]; 
            plot([0 1601],HrzL,'k');          
end

  % highlight example curve
    for i=sub_sel
        idx=3;
        for k= 4
          hold on 
            Rpred_Temp = Rpred_Output{i}(k,:);
            Rpred_Temp = Rpred_Temp';
            subplot(5,1,idx);
                plot(Rpred_Temp,'color',[0.8500, 0.3250, 0.0980],'LineWidth',2);
        end
    end

% Mean curve for this subject
for i=mod_sel    % use for mean curve (also ***)
    idx=4;
    for k= sub_sel   %  ***        
        files_parts = strsplit(files{i},'_');
        files_parts_classifier = strsplit(string(files_parts(end)),'.mat');
                
        Rpred_Temp = Rpred_Output_Mean{i}(k,:);   %  ***
        x = Feature_Output_Mean{i}(k,:);   %  ***   

        Rpred_Temp = Rpred_Temp';
        Rpred_Temp = Rpred_Temp / max(abs(Rpred_Temp));    % normalise to max (can be - or +) value
        x = x';
        t(1:size(Rpred_Temp,1),1) = (1:size(Rpred_Temp,1));

        filename = strcat(path,'_',files_parts_classifier(1));

        cmap = colormap(jet);
        cmin = -1;
        cmax = +1;
        c = round(1+(size(cmap,1)-1)*(Rpred_Temp - cmin)/(cmax-cmin));
        c(isnan(c)) = (size(cmap,1)/2);      
        VrtL = [-1:1:102];

        subplot(5,1,idx);
        PlotPos = get(gca,'Position') ;
        LftCorner = [(PlotPos(1)/5) PlotPos(2)];
            PlotWidths = PlotPos(3)/8;
            PlotHeights = PlotPos(4)/3  ;
        
        for m=1:8
            plot(t((m-1)*200+1:(m)*200),(x((m-1)*200+1:(m)*200)).*100,'linestyle','none');
            for l=(m-1)*200+1:(((m-1)*200)+size(x((m-1)*200+1:(m)*200),1)-1)
                line(t(l:l+1),(x(l:l+1)).*100,'color',cmap(c(l),:),'lineWidth',2.5)
            end            
            hold on                
%           Add vertical lines between muscles and label muscle columns 
            xticks([0:50:1600])
            xticklabels('')
            
            VrtLloc = zeros(length(VrtL),1);
            VrtLloc(:,:) = 200*m;
            plot(VrtLloc,VrtL,'k');

                if m == 1
                 yticks([0:50:100]);
                 xticklabels('') ;
                 a_tmp = get(gca,'YTickLabel');
                 set(gca,'YTickLabel',a_tmp,'fontsize',16);
                end
        end
        
         % Calculate areas with relevance score <> a threshold and color
         % black to highlight high (both + an -) relevance scores
            ThrshHld = 0;
            BelowThrsH = find(Rpred_Temp < ThrshHld);
            ThrsGrps = find(diff(BelowThrsH)>1);
            ThrsExLoc = BelowThrsH(ThrsGrps);
            ThrsExLoc2 = BelowThrsH(ThrsGrps+1);

            Thrsbars = zeros((length(ThrsGrps)+1)*2,1);
            Thrsbars(1,1) = BelowThrsH(1,1);
            for tlr = 1:length(ThrsGrps)
                Thrsbars(tlr*2) = ThrsExLoc(tlr);
            end
            for tlr = 1:length(ThrsGrps)
                Thrsbars((tlr*2)+1) = ThrsExLoc2(tlr);
            end
            Thrsbars(end,1) = BelowThrsH(end,1); 
            
            for tlr=1:(length(Thrsbars)/2)
                plot(t((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr)))),(x((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr))))).*100,'color','k','lineWidth',2.5)       % color black 
            end  

     % Create x-axis ticks at 25,50,75% of the cycle and remove top axis ticks
        hold off
        ax_org = gca;
            box off
            ax1 = gca;
            ax2 = axes('Position', get(ax1, 'Position'),...
                       'Color','None','XColor','none','YColor','k',...
                       'XAxisLocation','top', 'XTick', [],... 
                       'YAxisLocation','right', 'YTick', []);
             linkaxes([ax1, ax2])                  

        xlim([0 1600]);
        ylim([0 100]);
        hold on
            HrzL = [0 0]; 
            plot([0 1601],HrzL,'k');
        ClrbrLoc = [(PlotPos(1)+(1.02*PlotPos(3))) (PlotPos(2)) 0.02 PlotPos(4)] ;
        Cb = colorbar('Position',ClrbrLoc);
        Cb.TickLabels = {-1;0;1};      
        clearvars cmap cmin cmax c x t Rpred_Temp files_parts_class_title
    end
end


 clear all
 clc
 
 %%%%%%%%%%%
 %%%%% load latest data (need HighRelevance variables)  
 %%%%%%%%%%%
   SbjNms = AllData.Cycling.Day1.SbjNms(1:end-1);
 
   % Plot signature map
      idx=5;
        ha = subplot(5,1,idx);
          for j = 1
            k = 1 ;         
            HrzL = zeros(1,2); 
              axes(ha(1));                           
            plot([0 201],HrzL,'k');                            
             for m=1:8
                hold on
                 HrzL(HrzL==(m-1)) = m; 
                plot([0 201],HrzL,'Color',[0.5 0.5 0.5]);            
                ylim([0 8]);
                xlim([1 200]);
                set(gcf,'Color','w');
                PlotPos = get(gca,'Position') ;
                LftCorner = [(PlotPos(1)/5) PlotPos(2)];
                    PlotWidths = PlotPos(3)/8;
                    PlotHeights = PlotPos(4)/3  ;                    
                      xlabel('time (% of cycle)','FontSize',16);
                        xticks([1 200])
                        xticklabels({'0','100'})    
                         a_tmp = get(gca,'XTickLabel');
                         set(gca,'XTickLabel',a_tmp,'fontsize',16);                        
                         set(gca,'YTickLabel', [])                

                 % Add shaded highlighting to high positive relevance areas
                    Locss = find(AllData.Cycling.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(m))) > 29)';
                    if isempty(Locss)==0
                        LocSplits = find(diff(Locss)>1);
                        LocsExLoc = Locss(LocSplits);
                        LocsExLoc2 = Locss(LocSplits+1);

                        xbars = zeros((length(LocSplits)+1)*2,1);
                        xbars(1,1) = Locss(1,1);
                        for tlr = 1:length(LocSplits)
                            xbars(tlr*2) = LocsExLoc(tlr);
                        end
                        for tlr = 1:length(LocSplits)
                            xbars((tlr*2)+1) = LocsExLoc2(tlr);
                        end
                        xbars(end,1) = Locss(end,1);
                    hold on;
                    yLmmx = 9-m;
                    yLmmn = 8-m ;           
                    for tlr = 1:length(LocSplits)+1
                        p1 = patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[yLmmn yLmmx yLmmx yLmmn], cbs(m,:));
                        set(p1,'FaceAlpha',1,'EdgeColor','none');
                    end      
                    end
             end
                    set(gca,'LineWidth',0.5,'YTickLabel','');  
                  set(gca,'YTick',[]);  
                VrtL = [-0.1:0.1:8.1];                  
                for lpk = 1:3
                    VrtLloc = zeros(length(VrtL),1);                   
                    VrtLloc(:,:) = 50*lpk;
                    plot(VrtLloc,VrtL,'k','LineStyle','--'); 
                end
          end

clearvars -except RpredAct_Output Feature_Output main_dir


%% Results figure
     %%%%%%%%%%%
     %%%%% DO NOT use data from signature figure above but from start
     %%%%% script - slightly different because of when averaging is done
     %%%%%%%%%%% 
     
%% Cycling (top panel)     
clear all
clc
main_dir = 'C:\';
cd(main_dir);
liste = dir(fullfile(main_dir,'*.mat'));
files = {liste.name};
mod_sel = [4];

  %% Organise data
    for i=mod_sel  %:size(files,2)
      load(files{i})    
      Rpred_Output = RpredAct_Output;
        for k=1:size(Rpred_Output,2)  
            if isempty(Rpred_Output{k}) == 1
            else
                for m=1:size(Rpred_Output{k},1)
                    Rpred_Norm_Output{k}(m,:) = Rpred_Output{k}(m,:) / Ypred_Output{k}(m,k);
                end

                Rpred_Output_Mean{i}(k,:) = nanmean(Rpred_Output{k});
                Rpred_Output_SD{i}(k,:) = nanstd(Rpred_Output{k});

                Feature_Output_Mean{i}(k,:) = nanmean(Feature_Output{k});
                Feature_Output_SD{i}(k,:) = nanstd(Feature_Output{k});
            end
        end    
    end
    
% Mean curve for this subject
  figure(5);
  set(gcf,'Color','w','units','normalized','outerposition',[0 0 1 1]);
   sub_sel = [2 3 7];
   i = 4;
   idx=1;
    for k= sub_sel   %  ***        
        files_parts = strsplit(files{i},'_');
        files_parts_classifier = strsplit(string(files_parts(end)),'.mat');
                
        Rpred_Temp = Rpred_Output_Mean{i}(k,:);   %  ***
        x = Feature_Output_Mean{i}(k,:);   %  ***   

        Rpred_Temp = Rpred_Temp';
        Rpred_Temp = Rpred_Temp / max(abs(Rpred_Temp));    % normalise to max (can be - or +) value
        x = x';
        t(1:size(Rpred_Temp,1),1) = (1:size(Rpred_Temp,1));

        cmap = colormap(jet);
        cmin = -1;
        cmax = +1;
        c = round(1+(size(cmap,1)-1)*(Rpred_Temp - cmin)/(cmax-cmin));
        c(isnan(c)) = (size(cmap,1)/2);      
        VrtL = [-1:1:102];

        subplot(6,1,idx);
        PlotPos = get(gca,'Position') ;
        LftCorner = [(PlotPos(1)/5) PlotPos(2)];
            PlotWidths = PlotPos(3)/8;
            PlotHeights = PlotPos(4)/3  ;
            if idx == 1
               TitlePos = [(PlotPos(1) + (((1))* PlotWidths/3.8)) (PlotPos(2) + (1.1* PlotPos(4)))  PlotWidths PlotHeights]   ;     
               a1 = annotation('textbox',TitlePos,'String','Cycling','Fontsize',16,'EdgeColor','w'); 
               TitlePos = [(PlotPos(1) + (((1))* PlotWidths/3.8)) (PlotPos(2) - (3.2* PlotPos(4)))  PlotWidths PlotHeights]   ;     
               a1 = annotation('textbox',TitlePos,'String','Walking','Fontsize',16,'EdgeColor','w'); 
            end
        
        for m=1:8
            plot(t((m-1)*200+1:(m)*200),(x((m-1)*200+1:(m)*200)).*100,'linestyle','none');
            for l=(m-1)*200+1:(((m-1)*200)+size(x((m-1)*200+1:(m)*200),1)-1)
                line(t(l:l+1),(x(l:l+1)).*100,'color',cmap(c(l),:),'lineWidth',2.5)
            end            
            hold on                
%           Add vertical lines between muscles and label muscle columns 
            VrtLloc = zeros(length(VrtL),1);
            VrtLloc(:,:) = 200*m;
            plot(VrtLloc,VrtL,'k');
            
            xticks([0:50:1600])            
            xticklabels('')
                if m == 1
                 ylabel('');
                 yticks([0:50:100]);
                 xticklabels('') ;
                 a_tmp = get(gca,'YTickLabel');
                 set(gca,'YTickLabel',a_tmp,'fontsize',16);
                end         
                title(char(['Participant ' num2str(k)]),'FontSize', 13)
        end
        
         % Calculate areas with relevance score <> a threshold and color
         % black to highlight high (both + an -) relevance scores
            ThrshHld = 0;
            BelowThrsH = find(Rpred_Temp < ThrshHld);
            ThrsGrps = find(diff(BelowThrsH)>1);
            ThrsExLoc = BelowThrsH(ThrsGrps);
            ThrsExLoc2 = BelowThrsH(ThrsGrps+1);

            Thrsbars = zeros((length(ThrsGrps)+1)*2,1);
            Thrsbars(1,1) = BelowThrsH(1,1);
            for tlr = 1:length(ThrsGrps)
                Thrsbars(tlr*2) = ThrsExLoc(tlr);
            end
            for tlr = 1:length(ThrsGrps)
                Thrsbars((tlr*2)+1) = ThrsExLoc2(tlr);
            end
            Thrsbars(end,1) = BelowThrsH(end,1); 
            
            for tlr=1:(length(Thrsbars)/2)
                plot(t((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr)))),(x((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr))))).*100,'color','k','lineWidth',2.5)       % color black 
            end  
            
         % Add shaded highlighting to high positive relevance areas
            ThrshHld = 0.2;
            Locss = find(Rpred_Temp > ThrshHld);         
            LocSplits = find(diff(Locss)>1);
            LocsExLoc = Locss(LocSplits);
            LocsExLoc2 = Locss(LocSplits+1);

            xbars = zeros((length(LocSplits)+1)*2,1);
            xbars(1,1) = Locss(1,1);
            for tlr = 1:length(LocSplits)
                xbars(tlr*2) = LocsExLoc(tlr);
            end
            for tlr = 1:length(LocSplits)
                xbars((tlr*2)+1) = LocsExLoc2(tlr);
            end
            xbars(end,1) = Locss(end,1);

            hold on
            for tlr = 1:length(LocSplits)+1
            p1=patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[min(ylim) max(ylim) max(ylim) min(ylim)], 'b');
            set(p1,'FaceAlpha',0.15,'EdgeColor','none');
            end        

         % Create x-axis ticks at 25,50,75% of the cycle and remove top axis ticks
            hold off
            ax_org = gca;
                box off
                ax1 = gca;
                ax2 = axes('Position', get(ax1, 'Position'),...
                           'Color','None','XColor','none','YColor','k',...
                           'XAxisLocation','top', 'XTick', [],... 
                           'YAxisLocation','right', 'YTick', []);
                 linkaxes([ax1, ax2])                  

            xlim([0 1600]);
            ylim([0 100]);
            hold on
            HrzL = [0 0]; 
            plot([0 1601],HrzL,'k');
          ClrbrLoc = [(PlotPos(1)+(1.02*PlotPos(3))) (PlotPos(2)) 0.02 PlotPos(4)] ;
          Cb = colorbar('Position',ClrbrLoc);
          Cb.TickLabels = {-1;0;1};      
        clearvars cmap cmin cmax c x t Rpred_Temp files_parts_class_title
      idx = idx + 1;
    end

    
%% Walking (bottom panel)     
clear all
clc
main_dir = 'C:\Users\Jeroen\Nextcloud\Projects\Machine_Learning\Matlab\Results';
cd(main_dir);
liste = dir(fullfile(main_dir,'*.mat'));
files = {liste.name};
mod_sel = [6];

  %% Organise data
    for i=mod_sel  %:size(files,2)
      load(files{i})    
      Rpred_Output = RpredAct_Output;
        for k=1:size(Rpred_Output,2)  
            if isempty(Rpred_Output{k}) == 1
            else
                for m=1:size(Rpred_Output{k},1)
                    Rpred_Norm_Output{k}(m,:) = Rpred_Output{k}(m,:) / Ypred_Output{k}(m,k);
                end

                Rpred_Output_Mean{i}(k,:) = nanmean(Rpred_Output{k});
                Rpred_Output_SD{i}(k,:) = nanstd(Rpred_Output{k});

                Feature_Output_Mean{i}(k,:) = nanmean(Feature_Output{k});
                Feature_Output_SD{i}(k,:) = nanstd(Feature_Output{k});
            end
        end    
    end
    
% Mean curve for this subject
  set(gcf,'Color','w','units','normalized','outerposition',[0 0 1 1]);
   sub_sel = [2 3 7];
   i = 6;
   idx=4;
    for k= sub_sel   %  ***        
        files_parts = strsplit(files{i},'_');
        files_parts_classifier = strsplit(string(files_parts(end)),'.mat');
                
        Rpred_Temp = Rpred_Output_Mean{i}(k,:);   %  ***
        x = Feature_Output_Mean{i}(k,:);   %  ***   

        Rpred_Temp = Rpred_Temp';
        Rpred_Temp = Rpred_Temp / max(abs(Rpred_Temp));    % normalise to max (can be - or +) value
        x = x';
        t(1:size(Rpred_Temp,1),1) = (1:size(Rpred_Temp,1));

        cmap = colormap(jet);
        cmin = -1;
        cmax = +1;
        c = round(1+(size(cmap,1)-1)*(Rpred_Temp - cmin)/(cmax-cmin));
        c(isnan(c)) = (size(cmap,1)/2);      
        VrtL = [-1:1:102];

        subplot(6,1,idx);
        PlotPos = get(gca,'Position') ;
        LftCorner = [(PlotPos(1)/5) PlotPos(2)];
            PlotWidths = PlotPos(3)/8;
            PlotHeights = PlotPos(4)/3  ;
        
        for m=1:8
            plot(t((m-1)*200+1:(m)*200),(x((m-1)*200+1:(m)*200)).*100,'linestyle','none');
            for l=(m-1)*200+1:(((m-1)*200)+size(x((m-1)*200+1:(m)*200),1)-1)
                line(t(l:l+1),(x(l:l+1)).*100,'color',cmap(c(l),:),'lineWidth',2.5)
            end            
            hold on                
%           Add vertical lines between muscles and label muscle columns 
            xticks([0:50:1600])
            
            if idx == 6
                xticklabels({'0','','','','100'})                
            else
                xticklabels('')
            end            
            
            VrtLloc = zeros(length(VrtL),1);
            VrtLloc(:,:) = 200*m;
            plot(VrtLloc,VrtL,'k');

                if m == 1 && idx == 4
                 ylabel('EMG (%)','FontSize',16);
                 yticks([0:50:100]);
                 xticklabels('') ;
                 a_tmp = get(gca,'YTickLabel');
                 set(gca,'YTickLabel',a_tmp,'fontsize',16);                 
                elseif m == 1 
                 ylabel('');                    
                 yticks([0:50:100]);
                 xticklabels('') ;
                 a_tmp = get(gca,'YTickLabel');
                 set(gca,'YTickLabel',a_tmp,'fontsize',16);
                end         
                title(char(['Participant ' num2str(k)]),'FontSize', 13)
        end
        
         % Calculate areas with relevance score <> a threshold and color
         % black to highlight high (both + an -) relevance scores
            ThrshHld = 0;
            BelowThrsH = find(Rpred_Temp < ThrshHld);
            ThrsGrps = find(diff(BelowThrsH)>1);
            ThrsExLoc = BelowThrsH(ThrsGrps);
            ThrsExLoc2 = BelowThrsH(ThrsGrps+1);

            Thrsbars = zeros((length(ThrsGrps)+1)*2,1);
            Thrsbars(1,1) = BelowThrsH(1,1);
            for tlr = 1:length(ThrsGrps)
                Thrsbars(tlr*2) = ThrsExLoc(tlr);
            end
            for tlr = 1:length(ThrsGrps)
                Thrsbars((tlr*2)+1) = ThrsExLoc2(tlr);
            end
            Thrsbars(end,1) = BelowThrsH(end,1); 
            
            for tlr=1:(length(Thrsbars)/2)
                plot(t((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr)))),(x((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr))))).*100,'color','k','lineWidth',2.5)       % color black 
            end  
            
         % Add shaded highlighting to high positive relevance areas
            ThrshHld = 0.2;
            Locss = find(Rpred_Temp > ThrshHld);         
            LocSplits = find(diff(Locss)>1);
            LocsExLoc = Locss(LocSplits);
            LocsExLoc2 = Locss(LocSplits+1);

            xbars = zeros((length(LocSplits)+1)*2,1);
            xbars(1,1) = Locss(1,1);
            for tlr = 1:length(LocSplits)
                xbars(tlr*2) = LocsExLoc(tlr);
            end
            for tlr = 1:length(LocSplits)
                xbars((tlr*2)+1) = LocsExLoc2(tlr);
            end
            xbars(end,1) = Locss(end,1);

            hold on
            for tlr = 1:length(LocSplits)+1
            p1=patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[min(ylim) max(ylim) max(ylim) min(ylim)], 'b');
            set(p1,'FaceAlpha',0.15,'EdgeColor','none');
            end        

         % Create x-axis ticks at 25,50,75% of the cycle and remove top axis ticks
            hold off
            ax_org = gca;
                box off
                ax1 = gca;
                ax2 = axes('Position', get(ax1, 'Position'),...
                           'Color','None','XColor','none','YColor','k',...
                           'XAxisLocation','top', 'XTick', [],... 
                           'YAxisLocation','right', 'YTick', []);
                 linkaxes([ax1, ax2])                  

            xlim([0 1600]);
            ylim([0 100]);
            hold on
            HrzL = [0 0]; 
            plot([0 1601],HrzL,'k');
          ClrbrLoc = [(PlotPos(1)+(1.02*PlotPos(3))) (PlotPos(2)) 0.02 PlotPos(4)] ;
          Cb = colorbar('Position',ClrbrLoc);
          Cb.TickLabels = {-1;0;1};      
        clearvars cmap cmin cmax c x t Rpred_Temp files_parts_class_title
      idx = idx + 1;
    end


%% Further analyses and plots
muscle_nms = {'VL','RF','VM','GL','GM','SOL','TA','BF'};
cbs = [0,0,1;0,0,0;1,0,0;0,1,0;1,1,0;0,1,1;1,0,1;0.6350,0.0780,0.1840];
VrtL = [-1.2:0.01:1.2];
VrtLloc = zeros(241,1);
nrClc = 30;
nrSbj = length(Feature_Output);

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
    for k = 1:nrSbj 
        if isempty(Rpred_Output_pre{k}) == 1
        else           
            for l = 1:30
                Relevance_data.(char(['Subj',num2str(k)])).(char(['Cycle',num2str(l)])) = Rpred_Output{k}(l,:);
                MuscleActivation_data.(char(['Subj',num2str(k)])).(char(['Cycle',num2str(l)])) = Feature_Output{k}(l,:);
                GtlR_temp(l,:) = Rpred_Output{k}(l,:);
                GtlMA_temp(l,:) = Feature_Output{k}(l,:);
            end
            for i = 1:1600
                Relevance_data.(char(['Subj',num2str(k)])).(char('nanmean'))(1,i) = nanmean(GtlR_temp(:,i));
                MuscleActivation_data.(char(['Subj',num2str(k)])).(char('nanmean'))(1,i) = nanmean(GtlMA_temp(:,i));
            end
            clearvars GtlR_temp GtlMA_temp;
        end
    end
    
  % Re-evaluate nr of subjects because of missing subjects
    nrSbj = length(fieldnames(Relevance_data));
    SbjNms = fieldnames(Relevance_data);
    
    
  % Plot of relevance scores per cycle & per subject
    % plot for 1 subject, all cycles
     figure;
        PlotPos = get(gca,'Position') ;
            PlotWidths = PlotPos(3)/8;
            PlotHeights = PlotPos(4)/20  ;     
      hold on      
        for k = 2  
            for l = 1:nrClc
                plot(Relevance_data.(char(['Subj',num2str(k)])).(char(['Cycle',num2str(l)])),'b')
            end
            plot(Relevance_data.(char(['Subj',num2str(k)])).(char('nanmean')),'LineWidth',2,'color','r')
        end
        xlabel('datapoints');
        ylabel('relevance score');
        for m=1:8        
            VrtLloc(:,:) = 200*m;
            plot(VrtLloc,VrtL,'k');
             TitlePos = [(PlotPos(1) + (((m-1)+0.4)* PlotWidths)) 0.94  PlotWidths PlotHeights]   ;     
             a1 = annotation('textbox',TitlePos,'String',muscle_nms(m),'EdgeColor','w');
        end
        set(gcf,'Color','w');
          ylim([0 1]);
          set(figure(gcf),'units','normalized','outerposition',[0 0 1 1]);  
            cd(strcat(main_dir,'\Figures\Relevance_Plots\Cycling\Day1\150W'));
            print(figure(gcf),'Relevance_ExampleSubjectAllCycles','-djpeg','-r0');
            saveas(figure(gcf),strcat('Relevance_ExampleSubjectAllCycles','.fig'));

    % plot for all subjects, nanmean cycle
     figure;
        PlotPos = get(gca,'Position') ;
            PlotWidths = PlotPos(3)/8;
            PlotHeights = PlotPos(4)/20  ;     
      hold on          
        for k = 1:nrSbj  
            for l = 1           
                plot(Relevance_data.(char((char(SbjNms(k))))).(char('nanmean')))
            end
        end        
        xlabel('datapoints');
        ylabel('relevance score');
        for m=1:8        
            VrtLloc(:,:) = 200*m;
            plot(VrtLloc,VrtL,'k');
             TitlePos = [(PlotPos(1) + (((m-1)+0.4)* PlotWidths)) 0.94  PlotWidths PlotHeights]   ;     
             a1 = annotation('textbox',TitlePos,'String',muscle_nms(m),'EdgeColor','w');
        end
        set(gcf,'Color','w');
          ylim([0 1]);
          set(figure(gcf),'units','normalized','outerposition',[0 0 1 1]);  
            cd(strcat(main_dir,'\Figures\Relevance_Plots\Cycling\Day1\150W'));
            print(figure(gcf),'Relevance_AllSubjectMeanCycle','-djpeg','-r0');
            saveas(figure(gcf),strcat('Relevance_AllSubjectMeanCycle','.fig'));  
            
   % plot for all subject, all cycles
     figure;
        PlotPos = get(gca,'Position') ;
            PlotWidths = PlotPos(3)/8;
            PlotHeights = PlotPos(4)/20  ;     
      hold on      
        for k = 1:nrSbj
            for l = 1:nrClc
                plot(Relevance_data.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)])))
            end
            plot(Relevance_data.(char((char(SbjNms(k))))).(char('nanmean')),'LineWidth',2,'color','r')
        end
        xlabel('datapoints');
        ylabel('relevance score');
        for m=1:8        
            VrtLloc(:,:) = 200*m;
            plot(VrtLloc,VrtL,'k');
             TitlePos = [(PlotPos(1) + (((m-1)+0.4)* PlotWidths)) 0.94  PlotWidths PlotHeights]   ;     
             a1 = annotation('textbox',TitlePos,'String',muscle_nms(m),'EdgeColor','w');
        end
        set(gcf,'Color','w');
          ylim([0 1]);
          set(figure(gcf),'units','normalized','outerposition',[0 0 1 1]);  
            cd(strcat(main_dir,'\Figures\Relevance_Plots\Cycling\Day1\150W'));
            print(figure(gcf),'Relevance_AllSubjectsAllCycles','-djpeg','-r0');
            saveas(figure(gcf),strcat('Relevance_AllSubjectsAllCycles','.fig'));           
          
    % plot the single nanmean cycle calculated from all subjects
     figure;
        PlotPos = get(gca,'Position') ;
            PlotWidths = PlotPos(3)/8;
            PlotHeights = PlotPos(4)/20  ;     
      hold on          
        for k = 1:nrSbj  
            getallks(k,:) = Relevance_data.(char((char(SbjNms(k))))).(char('nanmean'));
            getallks2(k,:) = MuscleActivation_data.(char((char(SbjNms(k))))).(char('nanmean'));            
        end 
        for i = 1:1600
            Relevance_data.nanmean(1,i) = nanmean(getallks(:,i));
            MuscleActivation_data.nanmean(1,i) = nanmean(getallks(:,i));    
            Relevance_data.nanmean(2,i) = nanstd(getallks2(:,i));
            MuscleActivation_data.nanmean(2,i) = nanstd(getallks2(:,i));                
        end
        t = [1:1:1600];
          p1 = shadedErrorBar(t,Relevance_data.nanmean(1,:),Relevance_data.nanmean(2,:));
            set(p1.mainLine,'Color',[0 0.45 0])
            set(p1.patch,'EdgeColor','none')
            set(p1.patch,'FaceColor',[0 0.55 0])        
            set(p1.edge(1),'Color','none')
            set(p1.edge(2),'Color','none')
          plot(t,Relevance_data.nanmean(1,:),'LineWidth',1,'Color',[0 0.45 0])
                
        xlabel('datapoints');
        ylabel('relevance score');
        for m=1:8        
            VrtLloc(:,:) = 200*m;
            plot(VrtLloc,VrtL,'k');
             TitlePos = [(PlotPos(1) + (((m-1)+0.4)* PlotWidths)) 0.94  PlotWidths PlotHeights]   ;     
             a1 = annotation('textbox',TitlePos,'String',muscle_nms(m),'EdgeColor','w');
        end
        set(gcf,'Color','w');
          ylim([0 1]);
          set(figure(gcf),'units','normalized','outerposition',[0 0 1 1]);             
            cd(strcat(main_dir,'\Figures\Relevance_Plots\Cycling\Day1\150W'));
            print(figure(gcf),'Relevance_MeanAllSubjects','-djpeg','-r0');
            saveas(figure(gcf),strcat('Relevance_MeanAllSubjects','.fig'));               
            
   clearvars -except main_dir VrtL VrtLloc nrClc nrSbj Relevance_data MuscleActivation_data muscle_nms SbjNms
          
   AllData.Cycling.Day1.Relevance_data = Relevance_data;
   SbjNms = fieldnames(AllData.Cycling.Day1.Relevance_data);
   
%% Continue analyses with relevance above threshold   
  % Find relevance scores and muscle activations above specified thresholds
   Level_H = 0.2;      % highlight above this relevance threshold on plots
   Level_H_ma = 0.50;      % highlight above this muscle activation threshold on plots                        
    for k = 1:nrSbj    
        for l = 1:30
           Relev_Temp = AllData.Cycling.Day1.Relevance_data.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)]))';
           MuscleAct_Temp = MuscleActivation_data.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)]))';
            t(1:size(Relev_Temp,1),1) = (1:size(Relev_Temp,1));

          % Find relevance scores above threshold
            Locss = find(Relev_Temp > Level_H);

            for tlr = 1:8
              fnr = find(Locss > ((200*tlr)-200) & Locss < ((200*tlr)+1));
                if isempty(fnr)==0
                    AllData.Cycling.Day1.RelevanceScores.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)])).(char(muscle_nms(tlr))) = Locss(fnr)-(200*(tlr-1));
                else AllData.Cycling.Day1.RelevanceScores.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)])).(char(muscle_nms(tlr))) = 0;
                end
            end
            clearvars fnr tlr

          % Find muscle activation above threshold
            Locss2 = find(MuscleAct_Temp > Level_H_ma);

            for tlr = 1:8
              fnr = find(Locss2 > ((200*tlr)-199) & Locss2 < (200*tlr));
                if isempty(fnr)==0
                    MuscleActivationScores.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)])).(char(muscle_nms(tlr))) = Locss2(fnr)-(200*(tlr-1));
                else MuscleActivationScores.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)])).(char(muscle_nms(tlr))) = 0;
                end
            end      

            clearvars fnr tlr Locss Locss2 Rpred_Temp MuscleAct_Temp      
        end
           Relev_Temp_mean = AllData.Cycling.Day1.Relevance_data.(char((char(SbjNms(k))))).(char('nanmean'))';
           MuscleAct_Temp = MuscleActivation_data.(char((char(SbjNms(k))))).(char('nanmean'))';

      % Find relevance scores above threshold
        Locss_mean = find(Relev_Temp_mean > Level_H);

        for tlr = 1:8
          fnr = find(Locss_mean > ((200*tlr)-199) & Locss_mean < (200*tlr));
            if isempty(fnr)==0
                AllData.Cycling.Day1.RelevanceScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))) = Locss_mean(fnr)-(200*(tlr-1));
            else AllData.Cycling.Day1.RelevanceScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))) = 0;
            end
        end
        clearvars fnr tlr
        
      % Find muscle activation above threshold
        Locss2_mean = find(MuscleAct_Temp > Level_H_ma);

        for tlr = 1:8
          fnr = find(Locss2_mean > ((200*tlr)-199) & Locss2_mean < (200*tlr));
            if isempty(fnr)==0
                MuscleActivationScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))) = Locss2_mean(fnr)-(200*(tlr-1));
            else MuscleActivationScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))) = 0;
            end
        end      
        
        clearvars fnr t tlr Locss_mean Locss2_mean Rpred_Temp MuscleAct_Temp              
    end

  % Calculate incidence of high relevance per data point per muscle & per subject
    for k = 1:nrSbj   
         AllData.Cycling.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))) = rmfield(AllData.Cycling.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))),'FromMeanCycle');        
       for i = 1:length(muscle_nms)
         AllData.Cycling.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(i))) = zeros(1,200);
         HighMuscleActivationIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(i))) = zeros(1,200);
         HighMuscleActivationIncidence.(char((char(SbjNms(k))))).FromMeanCycle.(char(muscle_nms(i))) = zeros(1,200);
       end
    end
       for i = 1:length(muscle_nms)
         HighRelevanceIncidence.(char('AllSubjsAllCycles')).(char(muscle_nms(i))) = zeros(1,200);
         HighMuscleActivationIncidence.(char('AllSubjsAllCycles')).(char(muscle_nms(i))) = zeros(1,200);
         HighRelevanceIncidence.(char('AllSubjsMeanCycle')).(char(muscle_nms(i))) = zeros(1,200);
         AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsSignatureCycles')).(char(muscle_nms(i))) = zeros(1,1);         
         HighMuscleActivationIncidence.(char('AllSubjsMeanCycle')).(char(muscle_nms(i))) = zeros(1,200);         
       end
       
      for k = 1:nrSbj
          for l = 1:nrClc
            for tlr = 1:8 
              if AllData.Cycling.Day1.RelevanceScores.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)])).(char(muscle_nms(tlr))) == 0
              else  
                 Bngo(l,tlr) = 1;
              end          
            end
          end
          for tlr = 1:8
              if sum(Bngo(:,tlr)) == 30
                  AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsSignatureCycles')).(char(muscle_nms(tlr))) = AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsSignatureCycles')).(char(muscle_nms(tlr)))+ 1;
              else
              end
          end 
          clearvars Bngo BngoLoc
          Bngo = zeros(30,8);
          BngoLoc = zeros(200,8);
      end
      
      for k = 1:nrSbj
          for tlr = 1:8
          Bngo = zeros(30,200);
          Yeps = 0;
            for l = 1:nrClc
                for s = 1:200
                    if ismember(s,AllData.Cycling.Day1.RelevanceScores.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)])).(char(muscle_nms(tlr)))) == 0
                    else  
                       Bngo(l,s) = 1;
                    end 
                end
            end
            for s = 1:200            
              if sum(Bngo(:,s)) == 30
%                   Yeps = 1;
                    AllData.Cycling.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(tlr)))(1,s) = AllData.Cycling.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(tlr)))(1,s) + 1;
              end   
            end
%             if Yeps == 1
%                 AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsSignatureCycles')).(char(muscle_nms(tlr))) = AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsSignatureCycles')).(char(muscle_nms(tlr))) + 1;
%             end
          end
          clearvars Bngo BngoLoc
      end      
      
      
      for k = 1:nrSbj
         for tlr = 1:8  
             HighRelevanceIncidence.(char('AllSubjsAllCycles')).(char(muscle_nms(tlr))) = HighRelevanceIncidence.(char('AllSubjsAllCycles')).(char(muscle_nms(tlr))) + HighRelevanceIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(tlr)));
             HighMuscleActivationIncidence.(char('AllSubjsAllCycles')).(char(muscle_nms(tlr))) = HighMuscleActivationIncidence.(char('AllSubjsAllCycles')).(char(muscle_nms(tlr))) + HighMuscleActivationIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(tlr)));
         end
      end
      
      nrSbj = 78;
      SbjNms = AllData.Cycling.Day1.SbjNms;
      for k = 1:nrSbj
            for tlr = 1:8 
              if AllData.Cycling.Day1.RelevanceScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))) == 0
              else
                  for s = 1:200
                      Bngo = ismember(s,AllData.Cycling.Day1.RelevanceScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))));
                      if Bngo == 1
                          HighRelevanceIncidence.(char((char(SbjNms(k))))).FromMeanCycle.(char(muscle_nms(tlr)))(1,s) = HighRelevanceIncidence.(char((char(SbjNms(k))))).FromMeanCycle.(char(muscle_nms(tlr)))(1,s) + 1;                          
                          AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCycle')).(char(muscle_nms(tlr)))(1,s) = AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCycle')).(char(muscle_nms(tlr)))(1,s) + 1;
                      else
                      end
                  end
              end
              if AllData.Cycling.Day1.MuscleActivationScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))) == 0
              else
                  for s = 1:200
                      Bngo = ismember(s,AllData.Cycling.Day1.MuscleActivationScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))));
                      if Bngo == 1
                          HighMuscleActivationIncidence.(char((char(SbjNms(k))))).FromMeanCycle.(char(muscle_nms(tlr)))(1,s) = HighMuscleActivationIncidence.(char((char(SbjNms(k))))).FromMeanCycle.(char(muscle_nms(tlr)))(1,s) + 1;                                                    
                          AllData.Cycling.Day1.HighMuscleActivationIncidence.(char('AllSubjsMeanCycle')).(char(muscle_nms(tlr)))(1,s) = AllData.Cycling.Day1.HighMuscleActivationIncidence.(char('AllSubjsMeanCycle')).(char(muscle_nms(tlr)))(1,s) + 1;
                      else
                      end
                  end
              end           
            end
      end
      
      
   % Calculate incidence of peaks per muscle
       Level_H = 0.2;      % highlight above this relevance threshold on plots
       Lvl = 2;
       clearvars RelevanceScores HighRelevanceIncidence
       RelevanceScores = AllData.Cycling.Day1.RelevanceScores;
        for k = 1:nrSbj    
            for l = 1:30 % redundant loop?
                Relev_Temp_mean = Relevance_data.(char((char(SbjNms(k))))).(char('nanmean'))';
                Locss_mean = find(Relev_Temp_mean > Level_H);

                for tlr = 1:8
                  fnr = find(Locss_mean > ((200*tlr)-199) & Locss_mean < (200*tlr));
                    if isempty(fnr)==0
                        RelevanceScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))) = Locss_mean(fnr)-(200*(tlr-1));
                    else RelevanceScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))) = 0;
                    end
                end
                clearvars fnr tlr   
            end
        end
        for i = 1:8
           AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.(char(muscle_nms(i))) = zeros(78,1);
        end
          for k = 1:nrSbj
                for tlr = 1:8 
                  if RelevanceScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr))) == 0
                  else
                      Tmp_v = RelevanceScores.(char((char(SbjNms(k))))).(char('nanmean')).(char(muscle_nms(tlr)));
                      Pks = find(diff(Tmp_v)>1);
                        if isempty(Tmp_v) == 1
                        else
                          HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(muscle_nms(tlr))) = HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(muscle_nms(tlr))) + length(Pks);
                           AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.(char(muscle_nms(tlr)))(k,1) = 1;
                        end
                  end     
                end
          end
          
       % Compare how many subjects have features in VM AND VL and GM AND GL
          for k = 1:nrSbj
                for tlr = 1     
                    if AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.(char(muscle_nms(tlr)))(k,1) == 0
                    Chk1 = 0;
                    else Chk1 = 1;
                    end
                end
                for tlr = 3     
                    if AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.(char(muscle_nms(tlr)))(k,1) == 0
                    Chk2 = 0;
                    else Chk2 = 1;
                    end
                end       
                if Chk1 == 1 && Chk2 == 1
                    AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.VL_VM_list.(char((char(SbjNms(k))))) = 1;
                end
                clearvars Chk1 Chk2
                for tlr = 4     
                    if AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.(char(muscle_nms(tlr)))(k,1) == 0
                    Chk1 = 0;
                    else Chk1 = 1;
                    end
                end
                for tlr = 5     
                    if AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.(char(muscle_nms(tlr)))(k,1) == 0
                    Chk2 = 0;
                    else Chk2 = 1;
                    end
                end       
                if Chk1 == 1 && Chk2 == 1
                    AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.GL_GM_list.(char((char(SbjNms(k))))) = 1;
                end
                clearvars Chk1 Chk2    
          end
          AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.GL_GM_listNr = length(fieldnames(AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.GL_GM_list))
          AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.VL_VM_listNr = length(fieldnames(AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCyclePeaks')).(char(['Theshold_0_' num2str(Lvl)])).SubjectList.VL_VM_list))
                   


    clearvars Bngo i k l s tlr Relev_Temp Locss_mean Lvl Level_H Tmp_v
   
   
%     % Plot incidence for subjects over all cycles           
%       for Sbj = 1:10%nrSbj 
%         figure  ;
%            set(gcf,'color','w');
%            Mxv = 0;
%            Mxv2 = 0;          
%          for tlr = 1:length((muscle_nms))
%             if max(HighRelevanceIncidence.(char((char(SbjNms(Sbj))))).(char(muscle_nms(tlr)))) > Mxv
%                 Mxv = max(HighRelevanceIncidence.(char((char(SbjNms(Sbj))))).(char(muscle_nms(tlr))));
%             elseif max(HighMuscleActivationIncidence.(char((char(SbjNms(Sbj))))).(char(muscle_nms(tlr)))) > Mxv
%                 Mxv = max(HighMuscleActivationIncidence.(char((char(SbjNms(Sbj))))).(char(muscle_nms(tlr))));
%             end
%             if max(MuscleActivation_data.(char((char(SbjNms(Sbj))))).nanmean) > Mxv2
%                 Mxv2 = max(MuscleActivation_data.(char((char(SbjNms(Sbj))))).nanmean);
%             end            
%          end
%                 
%          for tlr = 1:length((muscle_nms))
%              set(gcf,'defaultAxesColorOrder',[[0 0.447 0.741]; [0.87 0.49 0]]);
%              subplot(8,1,tlr);            
%              yyaxis('left')
%              plot(HighRelevanceIncidence.(char((char(SbjNms(Sbj))))).(char(muscle_nms(tlr))),'LineWidth',1.2,'color',[0 0.447 0.741]);
%              hold on;             
%              plot(HighMuscleActivationIncidence.(char((char(SbjNms(Sbj))))).(char(muscle_nms(tlr))),'LineStyle','--','LineWidth',1,'color',[0 0.447 0.741]);                          
%              ylim([0 Mxv+5])             
%              yyaxis('right')             
%              plot(MuscleActivation_data.(char((char(SbjNms(Sbj))))).nanmean(1+((tlr-1)*200):((tlr)*200)),'LineWidth',1,'color',[0.87 0.49 0]);             
%              ylim([0 1])
%              
%            % Create x-axis ticks at 25,50,75% of the cycle and remove top axis ticks             
%             hold off;
%             yyaxis('left')
%             ax_org = gca;            
%             ylabel((char(muscle_nms(tlr))));
%             if tlr == length((muscle_nms))
%                 xlabel('time (datapoints)','Fontsize',10);
%             elseif tlr ==1 
%                 title(strcat('Subject:',' ',num2str(Sbj)));                
%             elseif tlr == round(length((muscle_nms))/2,0)
%                yyaxis('left')
%                 ylabel({strcat('incidence',' (',num2str(Level_H),'/',num2str(Level_H_ma),')'),(char(muscle_nms(tlr)))},'Fontsize',10);    
%                yyaxis('right')
%                 ylabel({'muscle activation'},'Fontsize',10);    
%             end
%             if tlr == length((muscle_nms))
%             else
%                 set(gca,'XTick', []);           
%             end            
%                 box off
%                 ax1 = gca;
%                 ax2 = axes('Position', get(ax1, 'Position'),...
%                            'Color','None','XColor','k','YColor','k',...
%                            'XAxisLocation','top', 'XTick', [],... 
%                            'YAxisLocation','right', 'YTick', []);
%                  linkaxes([ax1, ax2])        ;    
%                  
%          % Add shaded highlighting to high positive relevance areas
%             Locss = find(HighRelevanceIncidence.(char((char(SbjNms(Sbj))))).(char(muscle_nms(tlr))) > 0)';
%             if isempty(Locss)==0
%                 LocSplits = find(diff(Locss)>1);
%                 LocsExLoc = Locss(LocSplits);
%                 LocsExLoc2 = Locss(LocSplits+1);
% 
%                 xbars = zeros((length(LocSplits)+1)*2,1);
%                 xbars(1,1) = Locss(1,1);
%                 for tlr = 1:length(LocSplits)
%                     xbars(tlr*2) = LocsExLoc(tlr);
%                 end
%                 for tlr = 1:length(LocSplits)
%                     xbars((tlr*2)+1) = LocsExLoc2(tlr);
%                 end
%                 xbars(end,1) = Locss(end,1);
% 
%                 hold on
%                 for tlr = 1:length(LocSplits)+1
%                 p1=patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[min(ylim) max(ylim) max(ylim) min(ylim)], 'y');
%                 set(p1,'FaceAlpha',0.2,'EdgeColor','none');
%                 end    
%             end
%             clearvars Locss LocSplits LocsExLoc LocsExLoc2 xbars p1
%          end
%           set(figure(gcf),'units','normalized','outerposition',[0 0 1 1]);             
%             cd(strcat(main_dir,'\Figures\Individual_Incidence_plots\Threshold_0_2_highlightabove0'));
%             print(figure(gcf),char(strcat('Incidence_Subject',' ',num2str(Sbj))),'-djpeg','-r0');
% %             saveas(figure(gcf),strcat('Incidence_Subject:',' ',num2str(Sbj)),'.fig'));  
%             clearvars Mxv Mxv2 ax1 ax2 ax
%       end
%             
            
      % Plot incidence for all subjects over all cycles
         % (note that the incidence of muscle activation is not included here because of the
         % large difference in incidence between muscle activation (2000+) and relevance (180))
       
        figure  ;
           set(gcf,'color','w');
           Mxv = 0;
           Mxv2 = 0;
           
         for tlr = 1:length((muscle_nms))
            if max(AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCycle')).(char(muscle_nms(tlr)))) > Mxv
                Mxv = max(AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCycle')).(char(muscle_nms(tlr))));
            end
            if max(AllData.Cycling.Day1.MuscleActivation_data.nanmean) > Mxv2
                Mxv2 = max(AllData.Cycling.Day1.MuscleActivation_data.nanmean);
            end            
         end
                
         for tlr = 1:length((muscle_nms))
             set(gcf,'defaultAxesColorOrder',[[0 0.447 0.741]; [0.87 0.49 0]]);
             subplot(8,1,tlr);            
             yyaxis('left')
             plot(AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsMeanCycle')).(char(muscle_nms(tlr))),'LineWidth',1.2,'color',[0 0.447 0.741]);
             hold on;             
             ylim([0 30])   ;
             yticks([0 15 30])    ;  
             yticklabels([0 15 30])    ;                                   
             yyaxis('right')             
             plot(AllData.Cycling.Day1.MuscleActivation_data.nanmean(1,1+((tlr-1)*200):((tlr)*200)),'LineWidth',1,'color',[0.87 0.49 0]);             
             ylim([0 1])
             
           % Create x-axis ticks at 25,50,75% of the cycle and remove top axis ticks             
            hold off;
            yyaxis('left')
            ax_org = gca;            
            ylabel((char(muscle_nms(tlr))));
            if tlr == length((muscle_nms))
                xlabel('time (% cycle)','Fontsize',16);
            elseif tlr == round(length((muscle_nms))/2,0)
               yyaxis('left')
                ylabel({strcat('Incidence'),(char(muscle_nms(tlr)))},'Fontsize',16);    
               yyaxis('right')
                ylabel({'Mean muscle activation'},'Fontsize',16);    
            end
               aa_tmp = get(gca,'YTickLabel');
               set(gca,'YTickLabel',aa_tmp,'fontsize',16);          
            if tlr == length((muscle_nms))
               xticks([0 50 100 150 200])    ;  
               xticklabels([0 25 50 75 100])                    
               ab_tmp = get(gca,'XTickLabel');
               set(gca,'XTickLabel',ab_tmp,'fontsize',16);                              
            else
                set(gca,'XTick', []);           
            end            
                box off
                ax1 = gca;
                ax2 = axes('Position', get(ax1, 'Position'),...
                           'Color','None','XColor','None','YColor','None',...
                           'XAxisLocation','top', 'XTick', [],... 
                           'YAxisLocation','right', 'YTick', []);
                 linkaxes([ax1, ax2])        ;   
        
                 
         % Add shaded highlighting to high positive relevance areas
%             Locss = find(AllData.Cycling.Day1.HighRelevanceIncidence.(char('AllSubjsAllCycles')).(char(muscle_nms(tlr))) > 0)';
%             if isempty(Locss)==0
%                 LocSplits = find(diff(Locss)>1);
%                 LocsExLoc = Locss(LocSplits);
%                 LocsExLoc2 = Locss(LocSplits+1);
% 
%                 xbars = zeros((length(LocSplits)+1)*2,1);
%                 xbars(1,1) = Locss(1,1);
%                 for tlr = 1:length(LocSplits)
%                     xbars(tlr*2) = LocsExLoc(tlr);
%                 end
%                 for tlr = 1:length(LocSplits)
%                     xbars((tlr*2)+1) = LocsExLoc2(tlr);
%                 end
%                 xbars(end,1) = Locss(end,1);
% 
%                 hold on
%                 for tlr = 1:length(LocSplits)+1
%                 p1=patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[min(ylim) max(ylim) max(ylim) min(ylim)], 'y');
%                 set(p1,'FaceAlpha',0.2,'EdgeColor','none');
%                 end    
%             end
            clearvars Locss LocSplits LocsExLoc LocsExLoc2 xbars p1
         end
          set(figure(gcf),'units','normalized','outerposition',[0 0 1 1]);             
            cd(strcat(main_dir,'\Figures'));
            print(figure(gcf),'Incidence_AllSbjs','-djpeg','-r0');
            saveas(figure(gcf),strcat('Incidence_AllSbjs','.fig'));                
            


  % Scatter plots
     % prepare data
        rw=0;
          for k = 1:nrSbj    
             for l = 1:30    
                 rw=rw+1;
                 Relev_scatter_pre(rw,:) = AllData.Cycling.Day1.Relevance_data.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)]));
             end
          end             
         Szz = size(Relev_scatter_pre);
         Relev_scatter = reshape(Relev_scatter_pre,[1,Szz(1)*Szz(2)]);
          clearvars Relev_scatter_pre rw

         rw=0;
          for k = 1:nrSbj    
             for l = 1:30    
                 rw=rw+1;
                 MuscleAct_scatter_pre(rw,:) = AllData.Cycling.Day1.MuscleActivation_data.(char((char(SbjNms(k))))).(char(['Cycle',num2str(l)]));
             end
          end             
         Szz2 = size(MuscleAct_scatter_pre);
         MuscleAct_scatter = reshape(MuscleAct_scatter_pre,[1,Szz(1)*Szz(2)]);
          clearvars MuscleAct_scatter_pre rw     
          
        % Make negative muscle activation values NaNs
          tlr = 0;
           for i = 1:length(MuscleAct_scatter)
              if MuscleAct_scatter(1,i) < 0
                tlr = tlr+1;
                Zerolocs(1,tlr) = i;
              end              
           end
               Relev_scatter(Zerolocs) = NaN;
               MuscleAct_scatter(Zerolocs) = NaN;           
            
        % Remove NaNs
          tlr = 0;
           for i = 1:length(Relev_scatter)
              if isnan(Relev_scatter(1,i)) == 1
                tlr = tlr+1;
                NaNlocs(1,tlr) = i;
              end              
           end
               Relev_scatter(NaNlocs) = [];
               MuscleAct_scatter(NaNlocs) = [];            
            Thrs_rel_values = find(Relev_scatter > Level_H);
              
       % Use nanmeans per subject     
        rw=0;
          for k = 1:nrSbj    
             rw=rw+1;
             Relev_scatter_pre(rw,:) = AllData.Gait.Day1.Relevance_data.(char((char(SbjNms(k))))).nanmean;
          end             
         Szz = size(Relev_scatter_pre);
         Relev_scatter_MeanPerSubj = reshape(Relev_scatter_pre,[1,Szz(1)*Szz(2)]);
          clearvars Relev_scatter_pre rw

        rw=0;          
          for k = 1:nrSbj    
             rw=rw+1;
             MuscleAct_scatter_pre(rw,:) = AllData.Gait.Day1.MuscleActivation_data.(char((char(SbjNms(k))))).nanmean;
          end             
         Szz = size(MuscleAct_scatter_pre);
         MuscleAct_scatter_MeanPerSubj = reshape(MuscleAct_scatter_pre,[1,Szz(1)*Szz(2)]);
          clearvars MuscleAct_scatter_pre rw
          
        % Make negative muscle activation values NaNs
          tlr = 0;
           for i = 1:length(MuscleAct_scatter_MeanPerSubj)
              if MuscleAct_scatter_MeanPerSubj(1,i) < 0
                tlr = tlr+1;
                Zerolocs2(1,tlr) = i;
              end              
           end
               Relev_scatter_MeanPerSubj(Zerolocs2) = NaN;
               MuscleAct_scatter_MeanPerSubj(Zerolocs2) = NaN;   
               
        % Remove NaNs
          tlr = 0;
           for i = 1:length(Relev_scatter_MeanPerSubj)
              if isnan(Relev_scatter_MeanPerSubj(1,i)) == 1
                tlr = tlr+1;
                NaNlocs2(1,tlr) = i;
              end              
           end
               Relev_scatter_MeanPerSubj(NaNlocs2) = [];
               MuscleAct_scatter_MeanPerSubj(NaNlocs2) = [];                      
            Thrs_rel_values_MeanPerSubj = find(Relev_scatter_MeanPerSubj > Level_H); 
              clearvars tlr NaNlocs NaNlocs2 Zerolocs Zerolocs2 
            
    % Plot scatterplots
     % All cycles, all subjects
        figure
          scatter(MuscleAct_scatter,Relev_scatter,'marker','.')
          hold on
          scatter(MuscleAct_scatter(Thrs_rel_values),Relev_scatter(Thrs_rel_values),'g','marker','.')
            xlabel('muscle activation');
            ylabel('relevance score');
            set(gcf,'color','w');
            [r p] = corrcoef(MuscleAct_scatter,Relev_scatter);
            CorrelationCoeffs.AllCyclesAllSubjs.r = r(2,1);
            CorrelationCoeffs.AllCyclesAllSubjs.p = p(2,1);
             TitlePos = [0.2 0.6  0.1 0.05]   ;     
             a1 = annotation('textbox',TitlePos,'String',['R = ',num2str(round(r(2,1),2))],'EdgeColor','w','color','b');            
             TitlePos = [0.2 0.57  0.1 0.05]   ;     
             a1 = annotation('textbox',TitlePos,'String',['P = ',num2str(round(p(2,1),3))],'EdgeColor','w','color','b');            
            clearvars r p
            
           % Perform extra analysis: calculate mean muscle activation above 0.8 relevance
             % Get all values above 0.8 relevance
                  tlr = 0;
                   for i = 1:length(Relev_scatter)
                      if Relev_scatter(1,i) > 0.8
                        tlr = tlr+1;
                        Thrslocs2(1,tlr) = i;
                      end              
                   end
                       AllData.Gait.Day1.MuscleAct_scatter_Mean_0_8(1,1) = mean(MuscleAct_scatter(Thrslocs2));
                       AllData.Gait.Day1.MuscleAct_scatter_Mean_0_8(1,2) = std(MuscleAct_scatter(Thrslocs2));   
                       AllData.Gait.Day1.Relev_scatter_Mean_0_8(1,1) = mean(Relev_scatter(Thrslocs2));
                       AllData.Gait.Day1.Relev_scatter_Mean_0_8(1,2) = std(Relev_scatter(Thrslocs2));                          
                       
                 plot(MuscleAct_scatter_Mean_0_8(1,1),Relev_scatter_Mean_0_8(1,1),'d','markersize',10,'MarkerEdgeColor','k','Linewidth',3)
                    HrzLloc = [-0.05:0.01:1.05];
                    HrzL = zeros(111,1);
                    HrzL(:,:) = 0.8;
                    plot(HrzLloc,HrzL,'k','LineStyle','--');       
                    xlim([0 1]);
                    VrtL = [-0.05:0.01:Relev_scatter_Mean_0_8(1,1)];
                    VrtLloc = zeros(length(VrtL),1);
                    VrtLloc(:,:) = MuscleAct_scatter_Mean_0_8(1,1);
                    plot(VrtLloc,VrtL,'r','LineStyle','--');                       
                    ylim([0 1]);

            set(figure(gcf),'units','normalized','outerposition',[0 0 1 1]);             
            cd(strcat(main_dir,'\Figures\Correlations'));
            print(figure(gcf),'Corr_AllSbjsAllCycles','-djpeg','-r0');
            saveas(figure(gcf),strcat('Corr_AllSbjsAllCycles','.fig'));    
            
 %%
 %%%%%%%%%%%%%%%%%%
 %%% Figure 7 (Supplementary)
 %%%%%%%%%%%%%%%%%%       
     % nanmean cycles, all subjects    
        figure
          scatter(MuscleAct_scatter_MeanPerSubj.*100,Relev_scatter_MeanPerSubj,'marker','.','MarkerFaceColor','k','MarkerEdgeColor','k')
          hold on
          scatter(MuscleAct_scatter_MeanPerSubj(Thrs_rel_values_MeanPerSubj).*100,Relev_scatter_MeanPerSubj(Thrs_rel_values_MeanPerSubj),'marker','.','MarkerFaceColor','b','MarkerEdgeColor','b')

            set(gcf,'color','w');
            [r p] = corrcoef(MuscleAct_scatter_MeanPerSubj,Relev_scatter_MeanPerSubj);
            CorrelationCoeffs.AllCyclesAllSubjs.r = r(2,1);
            CorrelationCoeffs.AllCyclesAllSubjs.p = p(2,1);
             TitlePos = [0.2 0.6  0.1 0.05]   ;     
             a1 = annotation('textbox',TitlePos,'String',['R = ',num2str(round(r(2,1),2))],'FontSize',16','EdgeColor','w','color','k');            
             TitlePos = [0.2 0.55  0.1 0.05]   ;     
             a1 = annotation('textbox',TitlePos,'String',['P = ',num2str(round(p(2,1),3))],'FontSize',16','EdgeColor','w','color','k');            
            clearvars r p
            
           % Perform extra analysis: calculate mean muscle activation above 0.8 relevance
             % Get all values above 0.8 relevance
                  tlr = 0;
                  clearvars Thrslocs2
                   for i = 1:length(Relev_scatter_MeanPerSubj)
                      if Relev_scatter_MeanPerSubj(1,i) > 0.8
                        tlr = tlr+1;
                        Thrslocs2(1,tlr) = i;
                      end              
                   end
                       AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_8_fromMeanPerSubj(1,1) = mean(MuscleAct_scatter_MeanPerSubj(Thrslocs2));
                       AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_8_fromMeanPerSubj(1,2) = std(MuscleAct_scatter_MeanPerSubj(Thrslocs2));   
                       AllData.Cycling.Day1.Relev_scatter_Mean_0_8_fromMeanPerSubj(1,1) = mean(Relev_scatter_MeanPerSubj(Thrslocs2));
                       AllData.Cycling.Day1.Relev_scatter_Mean_0_8_fromMeanPerSubj(1,2) = std(Relev_scatter_MeanPerSubj(Thrslocs2));                          
                       CI_MAct_95_0_8(1,1) = mean(MuscleAct_scatter_MeanPerSubj(Thrslocs2)) - (1.96 * (std(MuscleAct_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       CI_MAct_95_0_8(1,2) = mean(MuscleAct_scatter_MeanPerSubj(Thrslocs2)) + (1.96 * (std(MuscleAct_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       CI_Rel_95_0_8(1,1) = mean(Relev_scatter_MeanPerSubj(Thrslocs2)) - (1.96 * (std(Relev_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       CI_Rel_95_0_8(1,2) = mean(Relev_scatter_MeanPerSubj(Thrslocs2)) + (1.96 * (std(Relev_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))

                       
             % Get all values above 0.2 relevance
                  tlr = 0;
                  clearvars Thrslocs2                  
                   for i = 1:length(Relev_scatter_MeanPerSubj)
                      if Relev_scatter_MeanPerSubj(1,i) > 0.2
                        tlr = tlr+1;
                        Thrslocs2(1,tlr) = i;
                      end              
                   end
                       AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_2_fromMeanPerSubj(1,1) = mean(MuscleAct_scatter_MeanPerSubj(Thrslocs2));
                       AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_2_fromMeanPerSubj(1,2) = std(MuscleAct_scatter_MeanPerSubj(Thrslocs2));   
                       AllData.Cycling.Day1.Relev_scatter_Mean_0_2_fromMeanPerSubj(1,1) = mean(Relev_scatter_MeanPerSubj(Thrslocs2));
                       AllData.Cycling.Day1.Relev_scatter_Mean_0_2_fromMeanPerSubj(1,2) = std(Relev_scatter_MeanPerSubj(Thrslocs2));                          
                       CI_MAct_95_0_2(1,1) = mean(MuscleAct_scatter_MeanPerSubj(Thrslocs2)) - (1.96 * (std(MuscleAct_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       CI_MAct_95_0_2(1,2) = mean(MuscleAct_scatter_MeanPerSubj(Thrslocs2)) + (1.96 * (std(MuscleAct_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       CI_Rel_95_0_2(1,1) = mean(Relev_scatter_MeanPerSubj(Thrslocs2)) - (1.96 * (std(Relev_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       CI_Rel_95_0_2(1,2) = mean(Relev_scatter_MeanPerSubj(Thrslocs2)) + (1.96 * (std(Relev_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))

                       
             % Get all values between 0 and 0.2 relevance
                  tlr = 0;
                  clearvars Thrslocs2                  
                   for i = 1:length(Relev_scatter_MeanPerSubj)
                      if Relev_scatter_MeanPerSubj(1,i) < 0.2
                        tlr = tlr+1;
                        Thrslocs2(1,tlr) = i;
                      end              
                   end
                       AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1) = mean(MuscleAct_scatter_MeanPerSubj(Thrslocs2));
                       AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,2) = std(MuscleAct_scatter_MeanPerSubj(Thrslocs2));   
                       AllData.Cycling.Day1.Relev_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1) = mean(Relev_scatter_MeanPerSubj(Thrslocs2));
                       AllData.Cycling.Day1.Relev_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,2) = std(Relev_scatter_MeanPerSubj(Thrslocs2));                          
                       CI_MAct_95_0_to_0_2(1,1) = mean(MuscleAct_scatter_MeanPerSubj(Thrslocs2)) - (1.96 * (std(MuscleAct_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       CI_MAct_95_0_to_0_2(1,2) = mean(MuscleAct_scatter_MeanPerSubj(Thrslocs2)) + (1.96 * (std(MuscleAct_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       CI_Rel_95_0_to_0_2(1,1) = mean(Relev_scatter_MeanPerSubj(Thrslocs2)) - (1.96 * (std(Relev_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       CI_Rel_95_0_to_0_2(1,2) = mean(Relev_scatter_MeanPerSubj(Thrslocs2)) + (1.96 * (std(Relev_scatter_MeanPerSubj(Thrslocs2))/sqrt(nrSbj)))
                       
                   eb1_H = errorbar(AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_8_fromMeanPerSubj(1,1).*100,AllData.Cycling.Day1.Relev_scatter_Mean_0_8_fromMeanPerSubj(1,1),((AllData.Cycling.Day1.Relev_scatter_Mean_0_8_fromMeanPerSubj(1,1))-(CI_Rel_95_0_8(1,1))),((AllData.Cycling.Day1.Relev_scatter_Mean_0_8_fromMeanPerSubj(1,1))-(CI_Rel_95_0_8(1,2))))
                   eb1_V = errorbar(AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_8_fromMeanPerSubj(1,1).*100,AllData.Cycling.Day1.Relev_scatter_Mean_0_8_fromMeanPerSubj(1,1),((AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_8_fromMeanPerSubj(1,1).*100)-(CI_MAct_95_0_8(1,1).*100)),((AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_8_fromMeanPerSubj(1,1).*100)-(CI_MAct_95_0_8(1,2).*100)),'horizontal')
                   set(eb1_H,'LineWidth',2,'Color','m')
                   set(eb1_V,'LineWidth',2,'Color','m')
                 plot(AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_8_fromMeanPerSubj(1,1).*100,AllData.Cycling.Day1.Relev_scatter_Mean_0_8_fromMeanPerSubj(1,1),'x','markersize',10,'MarkerEdgeColor','k','Linewidth',2)
                   
                   eb2_H = errorbar(AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_2_fromMeanPerSubj(1,1).*100,AllData.Cycling.Day1.Relev_scatter_Mean_0_2_fromMeanPerSubj(1,1),((AllData.Cycling.Day1.Relev_scatter_Mean_0_2_fromMeanPerSubj(1,1))-(CI_Rel_95_0_2(1,1))),((AllData.Cycling.Day1.Relev_scatter_Mean_0_2_fromMeanPerSubj(1,1))-(CI_Rel_95_0_2(1,2))))
                   eb2_V = errorbar(AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_2_fromMeanPerSubj(1,1).*100,AllData.Cycling.Day1.Relev_scatter_Mean_0_2_fromMeanPerSubj(1,1),((AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_2_fromMeanPerSubj(1,1).*100)-(CI_MAct_95_0_2(1,1).*100)),((AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_2_fromMeanPerSubj(1,1).*100)-(CI_MAct_95_0_2(1,2).*100)),'horizontal')
                   set(eb2_H,'LineWidth',2,'Color','r')
                   set(eb2_V,'LineWidth',2,'Color','r')
                 plot(AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_2_fromMeanPerSubj(1,1).*100,AllData.Cycling.Day1.Relev_scatter_Mean_0_2_fromMeanPerSubj(1,1),'x','markersize',10,'MarkerEdgeColor','k','Linewidth',2)
                   
                   eb3_H = errorbar(AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1).*100,AllData.Cycling.Day1.Relev_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1),((AllData.Cycling.Day1.Relev_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1))-(CI_Rel_95_0_to_0_2(1,1))),((AllData.Cycling.Day1.Relev_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1))-(CI_Rel_95_0_to_0_2(1,2))))
                   eb3_V = errorbar(AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1).*100,AllData.Cycling.Day1.Relev_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1),((AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1).*100)-(CI_MAct_95_0_to_0_2(1,1).*100)),((AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1).*100)-(CI_MAct_95_0_to_0_2(1,2).*100)),'horizontal')
                   set(eb3_H,'LineWidth',2,'Color','y')
                   set(eb3_V,'LineWidth',2,'Color','y')
                 plot(AllData.Cycling.Day1.MuscleAct_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1).*100,AllData.Cycling.Day1.Relev_scatter_Mean_0_to_0_2_fromMeanPerSubj(1,1),'x','markersize',10,'MarkerEdgeColor','k','Linewidth',2)

                    HrzLloc = [-0.05:0.01:1.05].*100;
                    HrzL = zeros(111,1);
                    HrzL(:,:) = 0.8;
                    plot(HrzLloc,HrzL,'k','LineStyle','--');       
                    xlim([0 100]);
                    VrtL = [-0.05:0.01:AllData.Gait.Day1.Relev_scatter_Mean_0_8_fromMeanPerSubj(1,1)];
                    VrtLloc = zeros(length(VrtL),1);
                    VrtLloc(:,:) = AllData.Gait.Day1.MuscleAct_scatter_Mean_0_8_fromMeanPerSubj(1,1).*100;
                    plot(VrtLloc,VrtL,'k','LineStyle','--');                       
                    ylim([0 1]);
                    set(gca,'FontSize',16);
                      xlabel('Relative EMG amplitude (%)','FontSize',18);
                     ylabel('Relevance score','FontSize',18);                    
                    

            set(figure(gcf),'units','normalized','outerposition',[0 0 1 1]);             
            cd(strcat(main_dir,'\Figures\Final_1'));
            print(figure(gcf),'Corr_AllSbjsMeanCycles','-djpeg','-r0');
            saveas(figure(gcf),strcat('Corr_AllSbjsMeanCycles','.fig'));  
            
                  
  % Create colormaps for single colors                 
    cbs = [0,0,1;0,0,0;1,0,0;0,1,0;1,1,0;0,1,1;1,0,1;0.6350,0.0780,0.1840];  
    Clrm_y = zeros(20,3);
    Clrm_y(:,1) = [0:(1/19):1]; 
    Clrm_y(:,2) = [0:(1/19):1];      
    Clrm_m = zeros(20,3);
    Clrm_m(:,1) = [0:(1/19):1]; 
    Clrm_m(:,3) = [0:(1/19):1];  
    Clrm_c = zeros(20,3);
    Clrm_c(:,2) = [0:(1/19):1]; 
    Clrm_c(:,3) = [0:(1/19):1];    
    Clrm_r = zeros(20,3);
    Clrm_r(:,1) = [0:(1/19):1];
    Clrm_g = zeros(20,3);
    Clrm_g(:,2) = [0:(1/19):1];    
    Clrm_b = zeros(20,3);
    Clrm_b(:,3) = [0:(1/19):1];   
    Clrm_k = zeros(20,3);
    Clrm_k(:,1) = [0:(0.8/19):0.8];      
    Clrm_k(:,2) = [0:(0.8/19):0.8];      
    Clrm_k(:,3) = [0:(0.8/19):0.8]; 
    Clrm_br = zeros(20,3);
    Clrm_br(:,1) = [0:(0.8500/19):0.8500];      
    Clrm_br(:,2) = [0:(0.3250/19):0.3250];      
    Clrm_br(:,3) = [0:(0.0980/19):0.0980];     
    
        figure
        hold on
        for i = 1:20
            plot(VrtLloc+i,VrtL+(2.5*0),'Color',Clrm_y(i,:))
        end
        for i = 1:20
            plot(VrtLloc+i,VrtL+(2.5*1),'Color',Clrm_r(i,:))
        end
        for i = 1:20
            plot(VrtLloc+i,VrtL+(2.5*2),'Color',Clrm_m(i,:))
        end
        for i = 1:20
            plot(VrtLloc+i,VrtL+(2.5*3),'Color',Clrm_c(i,:))
        end        
        for i = 1:20
            plot(VrtLloc+i,VrtL+(2.5*4),'Color',Clrm_g(i,:))
        end    
        for i = 1:20
            plot(VrtLloc+i,VrtL+(2.5*5),'Color',Clrm_b(i,:))
        end   
        for i = 1:20
            plot(VrtLloc+i,VrtL+(2.5*6),'Color',Clrm_k(i,:))
        end      
        for i = 1:20
            plot(VrtLloc+i,VrtL+(2.5*7),'Color',Clrm_br(i,:))
        end           
 
        

 %%
 %%%%%%%%%%%%%%%%%%
 %%% Figure 4
 %%%%%%%%%%%%%%%%%%
   % Plot signature maps for X participants Day 1 cycling and gait
       Sbjs2plot = 3;
       Sbjs_sel = [2 3 7];
       SbjNms = AllData.Cycling.Day1.SbjNms;
       Nms = {'A' 'B' 'C'};
        figure ;
            ha = tight_subplot(Sbjs2plot*2,1,[.01 .03],[0.1 0.1],[0.1 0.1])  ;
            k = 0;
          for j = 1:Sbjs2plot
              k = k+1;
            axes(ha(k));                           
             for m=1:8
                hold on
                ylim([0 8]);
                xlim([1 200]);
                set(gcf,'Color','w');
                PlotPos = get(gca,'Position') ;
                LftCorner = [(PlotPos(1)/5) PlotPos(2)];
                    PlotWidths = PlotPos(3)/8;
                    PlotHeights = PlotPos(4)/3  ; 
                    
                    if j == 2
                      ylabel({'Pedalling',strcat('P'," - ",num2str(Sbjs_sel(j)))},'FontSize',14);
                    else
                      ylabel({strcat('P'," - ",num2str(Sbjs_sel(j)))},'FontSize',14);                        
                    end
                    if k == Sbjs2plot
                      xlabel('time (% of cycle)','FontSize',14);
                    else
                      set(gca,'XColor', 'none');
                    end
                    set(gca,'YTickLabel', [])                           

                    Locss = find(AllData.Cycling.Day1.HighRelevanceIncidence.(char(['Subj' num2str(Sbjs_sel(j))])).(char(muscle_nms(m))) > 29)';
                    if isempty(Locss)==0
                        LocSplits = find(diff(Locss)>1);
                        LocsExLoc = Locss(LocSplits);
                        LocsExLoc2 = Locss(LocSplits+1);

                        xbars = zeros((length(LocSplits)+1)*2,1);
                        xbars(1,1) = Locss(1,1);
                        for tlr = 1:length(LocSplits)
                            xbars(tlr*2) = LocsExLoc(tlr);
                        end
                        for tlr = 1:length(LocSplits)
                            xbars((tlr*2)+1) = LocsExLoc2(tlr);
                        end
                        xbars(end,1) = Locss(end,1);
                    hold on;
                    yLmmx = 9-m;
                    yLmmn = 8-m ;           
                    for tlr = 1:length(LocSplits)+1
                        p1 = patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[yLmmn yLmmx yLmmx yLmmn], cbs(m,:));
                        set(p1,'FaceAlpha',1,'EdgeColor','none');
                    end      
                    end
                  VrtL2 = [-0.1:1:8.1];
                  for lpkk = 1:3
                      VrtLloc2(:,:) = zeros(length(VrtL2));
                      VrtLloc2(:,:) = 50*lpkk;              
                      plot(VrtLloc2,VrtL2,'k','LineStyle','--');   
                  end                      
                    clearvars Locss LocSplits LocsExLoc LocsExLoc2 xbars p1
             end
                  set(gca,'XTick',[]);                                  
                  set(gca,'YTick',[]);                                 
                    set(gca,'LineWidth',1.2,'YTickLabel','','FontSize',14);  
          end
          
          for j = 1:Sbjs2plot
              k = k+1;
            axes(ha(k));                                      
             for m=1:8
                hold on
                ylim([0 8]);
                xlim([1 200]);
                set(gcf,'Color','w');
                PlotPos = get(gca,'Position') ;
                LftCorner = [(PlotPos(1)/5) PlotPos(2)];
                    PlotWidths = PlotPos(3)/8;
                    PlotHeights = PlotPos(4)/3  ; 
                    if j == 2
                      ylabel({'Walking',strcat('P'," - ",num2str(Sbjs_sel(j)))},'FontSize',14);
                    else
                      ylabel({strcat('P'," - ",num2str(Sbjs_sel(j)))},'FontSize',14);                        
                    end
                    if k == Sbjs2plot*2
                      xlabel('time (% of cycle)','FontSize',14);
%                     else
%     %                   set(gca,'XColor', 'none');
                    end
                    set(gca,'YTickLabel', [])                

                    Locss = find(AllData.Gait.Day1.HighRelevanceIncidence.(char(['Subj' num2str(Sbjs_sel(j))])).(char(muscle_nms(m))) > 29)';
                    if isempty(Locss)==0
                        LocSplits = find(diff(Locss)>1);
                        LocsExLoc = Locss(LocSplits);
                        LocsExLoc2 = Locss(LocSplits+1);

                        xbars = zeros((length(LocSplits)+1)*2,1);
                        xbars(1,1) = Locss(1,1);
                        for tlr = 1:length(LocSplits)
                            xbars(tlr*2) = LocsExLoc(tlr);
                        end
                        for tlr = 1:length(LocSplits)
                            xbars((tlr*2)+1) = LocsExLoc2(tlr);
                        end
                        xbars(end,1) = Locss(end,1);
                    hold on;
                    yLmmx = 9-m;
                    yLmmn = 8-m ;           
                    for tlr = 1:length(LocSplits)+1
                        p1 = patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[yLmmn yLmmx yLmmx yLmmn], cbs(m,:));
                        set(p1,'FaceAlpha',1,'EdgeColor','none');
                    end      
                    end
                  VrtL2 = [-0.1:1:8.1];
                  VrtLloc2(:,:) = zeros(length(VrtL2));
                  VrtLloc2(:,:) = 130;              
                  plot(VrtLloc2,VrtL2,'k','LineStyle','--');                       
                    clearvars Locss LocSplits LocsExLoc LocsExLoc2 xbars p1
             end
                  set(gca,'YTick',[]);                                 
                    set(gca,'LineWidth',1.2,'YTickLabel','','FontSize',14);  
                    if k == Sbjs2plot*2
%                         set(gca,'XTick',[1 100 200],'XTickLabel',[0 50 100],'FontSize',14); 
                    else
                        set(gca,'XTick',[]); 
                    end
          end

          set(figure(gcf),'units','normalized','outerposition',[0 0 1 1]);  
          
            cd(strcat(main_dir,'\Figures\Final_1'));
            print(figure(gcf),['Signature_ExampleSubjects'],'-djpeg','-r0');
            saveas(figure(gcf),strcat('Signature_ExampleSubjects','.fig'));      
           

 %%
 %%%%%%%%%%%%%%%%%%
 %%% Figure 5 & 8 (Supplementary)
 %%%%%%%%%%%%%%%%%%            
   % Plot signature map
    % Pedalling
      X = 3;  % amount of figures
      for Lps = 1:X
       figure
          tlrk = 0;
        Sbjs2plot = 26;
            ha = tight_subplot(Sbjs2plot,1,[0.001 0.3],[0.1 0.1],[0.1 0.1])  ;       
          for j = 1:Sbjs2plot
            k = j+((78/X)*(Lps-1)) ;  
            tlrk = tlrk+1
            HrzL = zeros(1,2); 
              axes(ha(tlrk));                           

                set(gca,'box','on')
                ylim([0 8]);
                xlim([1 200]);
                set(gcf,'Color','w');
             
                    if Lps == 1 && j == 1 || Lps == 1 && j == 2 || Lps == 1 && j == 3 || Lps == 1 && j == 7
                     Yl1 = ylabel(strcat(char(['P' ' - ' num2str(j+((78/X)*(Lps-1)))]),"   "),'FontSize',16);
                       set(Yl1,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
                    elseif Lps == 1 && j == 4 || Lps == 1 && j == 5 || Lps == 1 && j == 6 
                     Yl2 = ylabel(strcat(char(['.']),"     "),'FontSize',20);
                       set(Yl2,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
                    elseif Lps == 1 && j == 15 || Lps == 1 && j == 16 || Lps == 1 && j == 17 
                     Yl3 = ylabel(strcat(char(['.']),"     "),'FontSize',20);
                       set(Yl3,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')   
                    elseif Lps == 2 && j == 12 || Lps == 2 && j == 13 || Lps == 2 && j == 14 
                     Yl4 = ylabel(strcat(char(['.']),"     "),'FontSize',20);
                       set(Yl4,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')                          
                    elseif Lps == X && j == 12 || Lps == X && j == 13 || Lps == X && j == 14 
                     Yl5 = ylabel(strcat(char(['.']),"     "),'FontSize',20);
                       set(Yl5,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')     
                    elseif  Lps == X && j == Sbjs2plot
                     Yl6 = ylabel(strcat(char(['P' ' - ' num2str(j+((78/X)*(Lps-1)))]),"   "),'FontSize',16);
                       set(Yl6,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')                       
                    else
                    end
                    if k == 78
                       Axsp = gca
                        set(Axsp,'Xtick',[1 100 200],'XTicklabels',[0 50 100]);  
                        set(Axsp,'TickLength',[0 0])
                        Axsp.XAxis.FontSize = 16;
                        Axsp.YAxis.FontSize = 16;
                        xlabel('time (% cycle)','FontSize',16);
                    end
                    set(gca,'YTickLabel', [])                    
                
             for m=1:8
                hold on
                      
                  VrtL2 = [-0.1:1:8.1];
                  VrtLloc2(:,:) = zeros(length(VrtL2));
                  VrtLloc2(:,:) = 20*m;              
                  plot(VrtLloc2,VrtL2,'k');                

                 % Add signature colors
                    Locss = find(AllData.Cycling.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(m))) > 29)';
                    if isempty(Locss)==0
                        LocSplits = find(diff(Locss)>1);
                        LocsExLoc = Locss(LocSplits);
                        LocsExLoc2 = Locss(LocSplits+1);

                        xbars = zeros((length(LocSplits)+1)*2,1);
                        xbars(1,1) = Locss(1,1);
                        for tlr = 1:length(LocSplits)
                            xbars(tlr*2) = LocsExLoc(tlr);
                        end
                        for tlr = 1:length(LocSplits)
                            xbars((tlr*2)+1) = LocsExLoc2(tlr);
                        end
                        xbars(end,1) = Locss(end,1);
                    hold on;
                    yLmmx = 9-m;
                    yLmmn = 8-m ;           
                    for tlr = 1:length(LocSplits)+1
                        p1 = patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[yLmmn yLmmx yLmmx yLmmn], cbs(m,:));
                        set(p1,'FaceAlpha',1,'EdgeColor','none');
                    end      
                    end
             end
                    set(gca,'LineWidth',0.5,'YTickLabel','');
              if k == 78
              else
                  set(gca,'XTick',[]);
              end
                  set(gca,'YTick',[]);    
                  VrtL2 = [-0.1:1:8.1];
                  for lpkk = 1:3
                      VrtLloc2(:,:) = zeros(length(VrtL2));
                      VrtLloc2(:,:) = 50*lpkk;              
                      plot(VrtLloc2,VrtL2,'k','LineStyle','--');   
                  end                               
          end
          set(figure(gcf),'units','normalized','outerposition',[0 0 0.5 1]);             
            cd(strcat(main_dir,'\Figures\Final_1'));
            saveas(figure(gcf),strcat(['Signature_overview_pt_correct' num2str(Lps)],'.fig'));             
            print(figure(gcf),['Signature_overview_pt_correct' num2str(Lps)],'-djpeg','-r0');
      end
            
        
    % Walking
      X = 3;  % amount of figures
      for Lps = 1:X
       figure
          tlrk = 0;
        Sbjs2plot = 26;
            ha = tight_subplot(Sbjs2plot,1,[0.001 0.3],[0.1 0.1],[0.1 0.1])  ;       
          for j = 1:Sbjs2plot
            k = j+((78/X)*(Lps-1)) ;  
            tlrk = tlrk+1
            HrzL = zeros(1,2); 
              axes(ha(tlrk));                           

                set(gca,'box','on')
                ylim([0 8]);
                xlim([1 200]);
                set(gcf,'Color','w');
             
                    if Lps == 1 && j == 1 || Lps == 1 && j == 2 || Lps == 1 && j == 3 || Lps == 1 && j == 7
                     Yl1 = ylabel(strcat(char(['P' ' - ' num2str(j+((78/X)*(Lps-1)))]),"   "),'FontSize',16);
                       set(Yl1,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
                    elseif Lps == 1 && j == 4 || Lps == 1 && j == 5 || Lps == 1 && j == 6 
                     Yl2 = ylabel(strcat(char(['.']),"     "),'FontSize',20);
                       set(Yl2,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
                    elseif Lps == 1 && j == 15 || Lps == 1 && j == 16 || Lps == 1 && j == 17 
                     Yl3 = ylabel(strcat(char(['.']),"     "),'FontSize',20);
                       set(Yl3,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')   
                    elseif Lps == 2 && j == 12 || Lps == 2 && j == 13 || Lps == 2 && j == 14 
                     Yl4 = ylabel(strcat(char(['.']),"     "),'FontSize',20);
                       set(Yl4,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')                          
                    elseif Lps == X && j == 12 || Lps == X && j == 13 || Lps == X && j == 14 
                     Yl5 = ylabel(strcat(char(['.']),"     "),'FontSize',20);
                       set(Yl5,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')     
                    elseif  Lps == X && j == Sbjs2plot
                     Yl6 = ylabel(strcat(char(['P' ' - ' num2str(j+((78/X)*(Lps-1)))]),"   "),'FontSize',16);
                       set(Yl6,'Rotation',0, 'VerticalAlignment','middle', 'HorizontalAlignment','right')                       
                    else
                    end
                    if k == 78
                       Axsp = gca
                        set(Axsp,'Xtick',[1 100 200],'XTicklabels',[0 50 100]);  
                        set(Axsp,'TickLength',[0 0])
                        Axsp.XAxis.FontSize = 16;
                        Axsp.YAxis.FontSize = 16;
                        xlabel('time (% cycle)','FontSize',16);
                    end
                    set(gca,'YTickLabel', [])                    
                
             for m=1:8
                hold on
                      
                  VrtL2 = [-0.1:1:8.1];
                  VrtLloc2(:,:) = zeros(length(VrtL2));
                  VrtLloc2(:,:) = 20*m;              
                  plot(VrtLloc2,VrtL2,'k');                

                 % Add signature colors
                    Locss = find(AllData.Gait.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(m))) > 29)';
                    if isempty(Locss)==0
                        LocSplits = find(diff(Locss)>1);
                        LocsExLoc = Locss(LocSplits);
                        LocsExLoc2 = Locss(LocSplits+1);

                        xbars = zeros((length(LocSplits)+1)*2,1);
                        xbars(1,1) = Locss(1,1);
                        for tlr = 1:length(LocSplits)
                            xbars(tlr*2) = LocsExLoc(tlr);
                        end
                        for tlr = 1:length(LocSplits)
                            xbars((tlr*2)+1) = LocsExLoc2(tlr);
                        end
                        xbars(end,1) = Locss(end,1);
                    hold on;
                    yLmmx = 9-m;
                    yLmmn = 8-m ;           
                    for tlr = 1:length(LocSplits)+1
                        p1 = patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[yLmmn yLmmx yLmmx yLmmn], cbs(m,:));
                        set(p1,'FaceAlpha',1,'EdgeColor','none');
                    end      
                    end
             end
                    set(gca,'LineWidth',0.5,'YTickLabel','');
              if k == 78
              else
                  set(gca,'XTick',[]);
              end
                  set(gca,'YTick',[]);    
                  VrtL2 = [-0.1:1:8.1];

                  for lpkk = 1:3
                  VrtLloc2(:,:) = zeros(length(VrtL2));
                  VrtLloc2(:,:) = 130;              
                  plot(VrtLloc2,VrtL2,'k','LineStyle','--');   
                  end                               
          end
          set(figure(gcf),'units','normalized','outerposition',[0 0 0.5 1]);             
            cd(strcat(main_dir,'\Figures\Final_2'));
            saveas(figure(gcf),strcat(['Signature_overview_pt_correct_Gait' num2str(Lps)],'.fig'));             
            print(figure(gcf),['Signature_overview_pt_correct_Gait' num2str(Lps)],'-dtiffn','-r0');
      end      
              

      
%% Results figure
 %%%%%%%%%%%%%%%%%%
 %%% Figure 2
 %%%%%%%%%%%%%%%%%%
 % No need for normalising! 
   figure(i);
    sub_sel = [2 3 7];
    muscle_nms = {'VL','RF','VM','GL','GM','SOL','TA','BF'};
    Level_H = 0.20;      % highlight above this relevance threshold on plots
    for i=mod_sel

        idx=1;

        for k= sub_sel

            files_parts = strsplit(files{i},'_');
            files_parts_classifier = strsplit(string(files_parts(end)),'.mat');

            Rpred_Temp = Rpred_Output_Mean{i}(k,:);
            x = Feature_Output_Mean{i}(k,:);

            Rpred_Temp = Rpred_Temp';
            x = x';
            t(1:size(Rpred_Temp,1),1) = (1:size(Rpred_Temp,1));

            filename = strcat(path,'_',files_parts_classifier(1));

            cmap = colormap(jet);
            cmin = min(min(Rpred_Temp));
            cmax = max(max(Rpred_Temp));
            c = round(1+(size(cmap,1)-1)*(Rpred_Temp - cmin)/(cmax-cmin));
            c(isnan(c)) = (size(cmap,1)/2);
            VrtL = [-1.2:0.01:1.2];

            subplot(5,1,idx);
            set(gcf,'Color','w');
            PlotPos = get(gca,'Position') ;
            LftCorner = [(PlotPos(1)/5) PlotPos(2)];
                PlotWidths = PlotPos(3)/8;
                PlotHeights = PlotPos(4)/3  ;

            for m=1:8
                plot(t((m-1)*200+1:(m)*200),x((m-1)*200+1:(m)*200),'linestyle','none');
                for l=(m-1)*200+1:(((m-1)*200)+size(x((m-1)*200+1:(m)*200),1)-1)
                    line(t(l:l+1),x(l:l+1),'color',cmap(c(l),:),'lineWidth',2.5)
                end            
                hold on

    %           Add vertical lines between muscles and label muscle columns 
                xticks([0:50:1600])
                xticklabels('')
                VrtLloc = zeros(241,1);
                VrtLloc(:,:) = 200*m;
                plot(VrtLloc,VrtL,'k');
                  if k == 1
                     TitlePos = [(PlotPos(1) + (((m-1)+0.4)* PlotWidths)) (PlotPos(2) + (1* PlotPos(4)))  PlotWidths PlotHeights]   ;     
                     a1 = annotation('textbox',TitlePos,'String',muscle_nms(m),'EdgeColor','w');
                  end
                  if k == median(sub_sel)
                     ylabel('muscle activation')
                  end           
            end

    %          % Calculate areas with relevance score <> a threshold and color
    %          % black to highlight high (both + an -) relevance scores
    %             ThrshHld = 0.4;
    %             aaT = median([1:1:64]);
    %             bbT = (64-aaT)*ThrshHld;
    %             BelowThrsH = find(c > (aaT-bbT) & c < (aaT+bbT));
    %             ThrsGrps = find(diff(BelowThrsH)>1);
    %             ThrsExLoc = BelowThrsH(ThrsGrps);
    %             ThrsExLoc2 = BelowThrsH(ThrsGrps+1);
    % 
    %             Thrsbars = zeros((length(ThrsGrps)+1)*2,1);
    %             Thrsbars(1,1) = BelowThrsH(1,1);
    %             for tlr = 1:length(ThrsGrps)
    %                 Thrsbars(tlr*2) = ThrsExLoc(tlr);
    %             end
    %             for tlr = 1:length(ThrsGrps)
    %                 Thrsbars((tlr*2)+1) = ThrsExLoc2(tlr);
    %             end
    %             Thrsbars(end,1) = BelowThrsH(end,1); 
    %             
    %             for tlr=1:(length(Thrsbars)/2)
    %                 plot(t((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr)))),x((Thrsbars((2*tlr)-1)):(Thrsbars((2*tlr)))),'color','k','lineWidth',2.5)       % color black 
    %             end  

         % Create x-axis ticks at 25,50,75% of the cycle and remove top axis ticks
            hold off
            ax_org = gca;
                box off
                ax1 = gca;
                ax2 = axes('Position', get(ax1, 'Position'),...
                           'Color','None','XColor','k','YColor','k',...
                           'XAxisLocation','top', 'XTick', [],... 
                           'YAxisLocation','right', 'YTick', []);
                 linkaxes([ax1, ax2])                  
            title([strcat('Subject ',string(k))]);

            xlim([0 1600]);
            ylim([0 1]);
            ClrbrLoc = [(PlotPos(1)+(1.02*PlotPos(3))) (PlotPos(2)) 0.02 PlotPos(4)] ;
            Cb = colorbar('Position',ClrbrLoc);
            Cb.TickLabels = {-1;0;1};

         % Add shaded highlighting to high positive relevance areas
            Locss = find(c > ((256/100)*(Level_H*100)));
            LocSplits = find(diff(Locss)>1);
            LocsExLoc = Locss(LocSplits);
            LocsExLoc2 = Locss(LocSplits+1);

            xbars = zeros((length(LocSplits)+1)*2,1);
            xbars(1,1) = Locss(1,1);
            for tlr = 1:length(LocSplits)
                xbars(tlr*2) = LocsExLoc(tlr);
            end
            for tlr = 1:length(LocSplits)
                xbars((tlr*2)+1) = LocsExLoc2(tlr);
            end
            xbars(end,1) = Locss(end,1);

            hold on
            for tlr = 1:length(LocSplits)+1
            p1=patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[min(ylim) max(ylim) max(ylim) min(ylim)], cmap(round((64/100)*(Level_H*100),0),:));
            set(p1,'FaceAlpha',0.2,'EdgeColor','none');
            end        
      

            idx=idx+1;

            clearvars cmap cmin cmax c x t Rpred_Temp files_parts_class_title

        end

        set(figure(i),'units','normalized','outerposition',[0 0 1 1])

    %     cd(strcat(main_dir,'\Figures'));
    %     print(figure(i),strcat('Subjs_',num2str(sub_sel(1)),'-',num2str(sub_sel(end)),'_',(files_parts_classifier(1))),'-dtiffn','-r0');
    %     saveas(figure(i),strcat('Subjs_',num2str(sub_sel(1)),'-',num2str(sub_sel(end)),'_',(files_parts_classifier(1)),'.fig'));
    end
      
clearvars a1 ha HrzL HrzLloc i j k l LftCorner LocsExLoc LocsExLoc2 LocSplits Locss Lps m maxx p1 Szz2 PlotHeights PlotPos PlotWidths Szz Sbjs2plot Thrs_rel_values Thrs_rel_values_MeanPerSubj Thrslocs2 TitlePos tlr VrtL2 VrtLloc2 X xbars yLmmn yLmmx
      

%% Robustness analyses
  % Store all variables in correct structure for robustness testing
    z=[who,who].';
    Strct =struct(z{:});
    PreStct = structvars(Strct,0);
      for i = 1:length(z)
         eval(PreStct(i,:));
      end
      NrSubjectsTest2.Subj_56 = Strct;
        clearvars -except NrSubjectsTest2  
        
      NrSubjectsTest.Subj_56 = NrSubjectsTest2.Subj_56
      
%% Numerical analyses
 % Between sessions analysis
 % Need to first check which subjects match between datasets
   tlrr = 1;
   Sbjnms_CD1 = fieldnames(AllData.Cycling.Day1.Relevance_data);
    Sbjnms_CD1(end,:) = [];   
   Sbjnms_CD2 = fieldnames(AllData.Cycling.Day2.Relevance_data);
    Sbjnms_CD2(end,:) = [];   
   Sbjnms_CP10 = fieldnames(AllData.Cycling.Perc10.Relevance_data);
    Sbjnms_CP10(end,:) = [];   
   Sbjnms_CP15 = fieldnames(AllData.Cycling.Perc15.Relevance_data);
   Sbjnms_GD1 = fieldnames(AllData.Gait.Day1.Relevance_data);
   Sbjnms_GD2 = fieldnames(AllData.Gait.Day2.Relevance_data);
%    Sbjnms_s56 = fieldnames(NrSubjectsTest.Subj_56.Relevance_data);
   
     [a b] = find(ismember(Sbjnms_CD1,Sbjnms_CD2));
       nmsss.Sbjs_CD1vsCD2 = Sbjnms_CD1(a,1);
       clearvars a b
     [a b] = find(ismember(Sbjnms_CD1,Sbjnms_CP10));
       nmsss.Sbjs_CD1vsCP10 = Sbjnms_CD1(a,1);       
       clearvars a b
     [a b] = find(ismember(Sbjnms_CD1,Sbjnms_CP15));
       nmsss.Sbjs_CD1vsCP15 = Sbjnms_CD1(a,1);       
       clearvars a b
     [a b] = find(ismember(Sbjnms_CD1,Sbjnms_GD1));
       nmsss.Sbjs_CD1vsGD1 = Sbjnms_CD1(a,1);       
       clearvars a b       
     [a b] = find(ismember(Sbjnms_GD1,Sbjnms_GD2));
       nmsss.Sbjs_GD1vsGD2 = Sbjnms_GD1(a,1);       
       clearvars a b     
     [a b] = find(ismember(Sbjnms_GD1,Sbjnms_CD1));
       nmsss.Sbjs_GD1vsCD1 = Sbjnms_GD1(a,1);       
       clearvars a b     
     [a b] = find(ismember(Sbjnms_CD1,Sbjnms_s56));
       Sbjs_CD1vsS56 = Sbjnms_CD1(a,1);
       clearvars a b
        nmeslst = fieldnames(nmsss);
       
     ConditionNms = {'CD1vsCD2','CD1vsCP10','CD1vsCP15','CD1vsGD1','GD1vsGD2'};
     Cnds1 = {'Cycling','Cycling','Cycling','Cycling','Gait'};
     Cnds2 = {'Cycling','Cycling','Cycling','Gait','Gait'};
     Grpz1 = {'Day1','Day1','Day1','Day1','Day1'};
     Grpz2 = {'Day2','Perc10','Perc15','Day1','Day2'};
     
     AllData.Gait = Gait;
   
  for lpr = 1:length(ConditionNms)
    Base_Grp1 = Cnds1(lpr)
    Base_Data1 = Grpz1(lpr)
    Base_Grp2 = Cnds2(lpr)   
    Base_Data2 = Grpz2(lpr)

    Cnd = ConditionNms{lpr}
    Sbjnms = nmsss.(char(nmeslst(lpr)));
    for Sbjj = 1:length(Sbjnms)
      % RMS for robustness data
       % RMS vector
         CcleA = AllData.(char(Base_Grp1)).(char(Base_Data1)).Relevance_data.(char(Sbjnms(Sbjj))).nanmean;
%          CcleB = NrSubjectsTest.(char(Base_Grp2)).Relevance_data.(char(Sbjnms(Sbjj))).nanmean;
         CcleB = AllData.(char(Base_Grp2)).(char(Base_Data2)).Relevance_data.(char(Sbjnms(Sbjj))).nanmean;
%          CcleDiff = zeros(1,length(CcleA));
% 
%          for i = 1:length(CcleA)
%              CcleDiff(1,i) = sqrt((CcleA(1,i)-CcleB(1,i)).^2);
%          end
%          plot(CcleDiff,'k')
% 
%        % Mean RMS value
%          RMSE(Sbjj,1) = sqrt(nanmean((CcleA-CcleB).^2));
         
%        % Cross-correlation analyseis
%          CcleA(isnan(CcleA)) = 0;
%          CcleB(isnan(CcleB)) = 0;
% 
%           [r,lags] = xcorr(CcleA,CcleB,'normalized');
%           Cross_Corr_Results.(char(Sbjnms(Sbjj))).r = r;
%           Cross_Corr_Results.(char(Sbjnms(Sbjj))).lag = lags;
%           meanrgetallekes(Sbjj,:) = r;
%           clearvars CcleA CcleB r lags 

       % Cross-correlation analyseis
         CcleA(isnan(CcleA)) = 0;
         CcleB(isnan(CcleB)) = 0;

          [r p] = corrcoef(CcleA,CcleB);
%           CorrelationCoeffs_Robustness.(char(Sbjnms(Sbjj))).r = r(2,1);
%           CorrelationCoeffs_Robustness.(char(Sbjnms(Sbjj))).p = p(2,1);
          meanrgetallekes(Sbjj,:) = r(2,1);
          clearvars CcleA CcleB r lags 
    end
    
    % RMSE 95% CI
      RMSE_tmp = Robustness_results.(char(Cnd)).RMSE;
       RMSE_CI(1,1) = mean(RMSE_tmp) - (1.96 * (std(RMSE_tmp)/sqrt(length(RMSE_tmp))));
       RMSE_CI(1,2) = mean(RMSE_tmp) + (1.96 * (std(RMSE_tmp)/sqrt(length(RMSE_tmp))));
        Robustness_results.(char(Cnd)).RMSE_CI = RMSE_CI;
       
    
    % Find r-values at 0 lag 
       clearvars peak_r z z_mean
        peak_r = meanrgetallekes;
    
    % Transform individual r-values to z-values (Fisher's transform)
      for i = 1:length(peak_r)
        z_temp = 0.5*log((1+peak_r(i,1))/(1-peak_r(i,1)));
%         Robustness_results.(char(Cnd)).Correlations.(char(Sbjnms(i))).z = z_temp;
        z(i,1) = z_temp;
        clearvars z_temp
      end
    
    % Calculate mean & CI of all z-values
       z_mean = mean(z);
       
       z_CI(1,1) = mean(z) - (1.96 * (std(z)/sqrt(length(z))));
       z_CI(1,2) = mean(z) + (1.96 * (std(z)/sqrt(length(z))));       
     
        clearvars mxx mxLag
        for i = 1:length(z)
             [Pk Pkloc] = max(Correlations.(char(Sbjnms(i))).r(1,:));
            mxx(i,1) = Pk;
            mxLag(i,1) = Correlations.(char(Sbjnms(i))).lag(1,Pkloc);
            clearvars Pk Pkloc;
    %         plot(mxx,'*')
        end
        
    % Transform mean & CI z-values back to r-value   
        z_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1);
        z_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
        z_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);

      Robustness_results.(char(Cnd)).Correlations_r_mean = z_final;         
      Robustness_results.(char(Cnd)).Correlations_r_CI = z_final_CI;         
      Robustness_results.(char(Cnd)).RMSE = RMSE;  
      Robustness_results.(char(Cnd)).RMSE_mean(1,1) = mean(RMSE);        
      Robustness_results.(char(Cnd)).RMSE_mean(1,2) = std(RMSE);      
        clearvars z_final_CI z_CI ans Base_Data1 Base_Grp1 Base_Grp2 Cnd NrSubjectsTest2 i meanrgetallekes mxLag mxx peak_r RMSE Sbjj Sbjnms_CD1 tlrr z z_final z_mean 
      
      Robustness_results.(char(Cnd)).RMSE = RMSE
      Robustness_results.(char(Cnd)).RMSE_mean(1,1) = mean(RMSE);
      Robustness_results.(char(Cnd)).RMSE_mean(1,2) = std(RMSE);
      Robustness_results.(char(Cnd)).Cross_Corr_Results = Cross_Corr_Results;
      Robustness_results.(char(Cnd)).Cross_Corr_Results.AVG.getallekes_r = meanrgetallekes;  
      Robustness_results.(char(Cnd)).Cross_Corr_Results.AVG.lag = Cross_Corr_Results.(char(Sbjnms(Sbjj))).lag;      
      
        for lp = 1:size(meanrgetallekes,2)
            Robustness_results.(char(Cnd)).Cross_Corr_Results.AVG.r(1,lp) = mean(meanrgetallekes(:,lp));
        end
  end

       fldnss = fieldnames(Robustness_results);
       fldnss(1:8,:) = [];
       tmpfn = fieldnames(Robustness_results);
       fldnss(5,:) = tmpfn(1);
       for i = 1:5
          Temp_RMSE_means(i,:) = Robustness_results.(char(fldnss(i))).RMSE_mean;
          Temp_XCorr_r(i,1) = Robustness_results.(char(fldnss(i))).Cross_Corr_Results.AVG.r_at_0_lag;
          Temp_XCorr_r(i,2) = 0;
          Temp_XCorr_lag_mean(i,:) = Robustness_results.(char(fldnss(i))).Cross_Corr_Results.AVG.lag_mean./2;
       end

     figure;
      hold on
       ylabel('RMSE value');
       xlabel('# of participants');
       set(gcf,'Color','w');          
         errorbar(Temp_RMSE_means(:,1),Temp_RMSE_means(:,2),'-o')
           xticks([1:1:5])
           xticklabels({'7','14','28','56','78'})      
           xlim([0.5 5.5])
           
     figure;
      hold on
       ylabel('Cross-correlation mean value');
       xlabel('# of participants');
       set(gcf,'Color','w');          
         errorbar(Temp_XCorr_r(:,1),Temp_XCorr_r(:,2),'-o')
           xticks([1:1:5])
           xticklabels({'7','14','28','56','78'})      
           xlim([0.5 5.5])           
          
     figure;
      hold on
       ylabel('Cross-correlation mean lag');
       xlabel('# of participants');
       set(gcf,'Color','w');          
         errorbar(Temp_XCorr_lag_mean(:,1),Temp_XCorr_lag_mean(:,2),'-o')
           xticks([1:1:5])
           xticklabels({'7','14','28','56','78'})      
           xlim([0.5 5.5]) 
           ylim([-2 2])

      
     figure;
      hold on
       ylabel('r-value');
       xlabel('lag');
       set(gcf,'Color','w');      
         for Sbjj = 1:Cycling.Day2.nrSbj
             plot(Cross_Corr_Results.(char(Sbjnms(Sbjj))).lag,Cross_Corr_Results.(char(Sbjnms(Sbjj))).r);
         end
         
     figure;
      hold on
       ylabel('r-value');
       xlabel('lag');
       set(gcf,'Color','w');      
       plot(Robustness_results.(char(Cnd)).Cross_Corr_Results.AVG.lag,Robustness_results.(char(Cnd)).Cross_Corr_Results.AVG.r);
         
     figure;
      hold on
       ylabel('r-value');
       xlabel('lag');
       ylim([0 1]);
       set(gcf,'Color','w');           
         for Sbjj = 1:Cycling.Day2.nrSbj
             [Pk Pkloc] = max(Cross_Corr_Results.(char(Sbjnms(Sbjj))).r);
             plot(Cross_Corr_Results.(char(Sbjnms(Sbjj))).lag(1,Pkloc),Pk,'*');
             clearvars Pk Pkloc
         end
      
    clearvars Base_Grp1 Base_Grp2 Base_Data1 Base_Data2 Cnd CndLp lp meanrgetallekes RMSE RMSE_mean Sbjj ans
      
    for Cnd = 1:length(ConditionNms)
      Robustness_results.Summary.RMSE_mean.(char(ConditionNms(Cnd))) = Robustness_results.(char(ConditionNms(Cnd))).RMSE_mean;
        [Pk Pkloc] = max(Robustness_results.(char(ConditionNms(Cnd))).Cross_Corr_Results.AVG.r);
      Robustness_results.Summary.Peak_r.(char(ConditionNms(Cnd))) = Pk;
      Robustness_results.Summary.Lag_atPeak_r.(char(ConditionNms(Cnd))) = Robustness_results.(char(ConditionNms(Cnd))).Cross_Corr_Results.AVG.lag(Pkloc);
      clearvars Pk Pkloc
    end
    

 % Between cycles (within subjects) analysis
    Sbjnms = Sbjnms_GD1;
    
     % method 1: calculate RMSE between each cycle per subject.
        tlr = 0;
        for Sbjj = 1:length(Sbjnms)
          % RMS for robustness data
             for k = 1:30
               % RMS vector
                 CcleA = AllData.Gait.Day1.Relevance_data.(char(Sbjnms(Sbjj))).(char(['Cycle' num2str(k)]));
                 lps = [1:1:30];
                 lps(lps==k) = [];
                    for l = 1:29
                       CcleB = AllData.Gait.Day1.Relevance_data.(char(Sbjnms(Sbjj))).(char(['Cycle' num2str(lps(l))]));
                       tlr=tlr+1;
                       RMSE_Temp(tlr,1) = sqrt(nanmean((CcleA-CcleB).^2));
                        clearvars  CcleB                   
                    end
                clearvars  CcleA                   
             end
        end
   

     % Mean RMS value
        RMSE_M1(1,1) = mean(RMSE_Temp);
        RMSE_M1(1,2) = std(RMSE_Temp);
        
        RMSE_M2(1,1) = mean(RMSE_Temp2);
        RMSE_M2(1,2) = std(RMSE_Temp2);
        
    % RMSE 95% CI
      RMSE_tmp = RMSE_Temp;
       RMSE_CI(1,1) = mean(RMSE_tmp) - (1.96 * (std(RMSE_tmp)/sqrt(length(RMSE_tmp))));
       RMSE_CI(1,2) = mean(RMSE_tmp) + (1.96 * (std(RMSE_tmp)/sqrt(length(RMSE_tmp))));
        Robustness_results.WithinSbj.GD1.RMSE_CI = RMSE_CI;        
    

     % method 1: calculate corr between each cycle per subject.
        tlr = 0;
        for Sbjj = 1:length(Sbjnms)
             for k = 1:30
                 CcleA = AllData.Cycling.Day1.Relevance_data.(char(Sbjnms(Sbjj))).(char(['Cycle' num2str(k)]));
                 CcleA(isnan(CcleA)) = 0;
                 
                 lps = [1:1:30];
                 lps(lps==k) = [];
                    for l = 1:29
                       CcleB = AllData.Cycling.Day1.Relevance_data.(char(Sbjnms(Sbjj))).(char(['Cycle' num2str(lps(l))]));
                       CcleB(isnan(CcleB)) = 0;
                       tlr=tlr+1;
                       [r,p] = corrcoef(CcleA,CcleB);
                       r_Temp(tlr,:) = r(2,1);
                        clearvars  CcleB                   
                    end
                clearvars  CcleA                   
             end
        end        

   % Correlation results averaging    
    % Find r-values at 0 lag
       clearvars peak_r z z_mean
         peak_r = r_Temp;
    
    % Transform individual r-values to z-values (Fisher's transform)
      for i = 1:length(peak_r)
        z_temp = 0.5*log((1+peak_r(i,1))/(1-peak_r(i,1)));
        z(i,1) = z_temp;
        clearvars z_temp
      end
    
    % Calculate mean of all z-values
       z_mean = mean(z);
       
       z_CI(1,1) = mean(z) - (1.96 * (std(z)/sqrt(length(z))));
       z_CI(1,2) = mean(z) + (1.96 * (std(z)/sqrt(length(z))));             
        
    % Transform mean z-value back to r-value   
        z_final = (exp(2*z_mean)-1)/(exp(2*z_mean)+1)
        z_final_CI(1,1) = (exp(2*z_CI(1,1))-1)/(exp(2*z_CI(1,1))+1);
        z_final_CI(1,2) = (exp(2*z_CI(1,2))-1)/(exp(2*z_CI(1,2))+1);        

      Robustness_results.WithinSbj.CD1.Correlations_r_mean = z_final; 
      Robustness_results.WithinSbj.CD1.Correlations_r_CI = z_final_CI;         
      
        figure
        hold on
        for i = 1:67860
             [Pk Pkloc] = max(r_Temp(i,:));
            mxx(i,1) = Pk;
            mxLag(i,1) = lags_Temp(i,Pkloc);
            clearvars Pk Pkloc;
            plot(mxx,'*')
        end
    
      Robustness_results.WithinSbj.GD1.RMSE_M1 = RMSE_M1;
      Robustness_results.WithinSbj.GD1.RMSE_M2 = RMSE_M2;      
      Robustness_results.WithinSbj.GD1.Cross_Corr_Results.r = r_Temp;
      Robustness_results.WithinSbj.GD1.Cross_Corr_Results.lag = lags_Temp(1,:);
      Robustness_results.WithinSbj.GD1.Cross_Corr_Results.AVG.r(1,1) = mean(mxx);  
      Robustness_results.WithinSbj.GD1.Cross_Corr_Results.AVG.r(1,2) = std(mxx);  
      Robustness_results.WithinSbj.GD1.Cross_Corr_Results.AVG.lag_mean(1,1) = mean(mxLag);      
      Robustness_results.WithinSbj.GD1.Cross_Corr_Results.AVG.lag_mean(1,2) = std(mxLag);      
      Robustness_results.WithinSbj.GD1.Cross_Corr_Results.AVG.lag_max = max(abs(mxLag));      
      
        clearvars i k l lags_Temp lps mxLag mxx r_Temp Sbjj tlr RMSE_M1 RMSE_M2
    

 %% Correlation between cycling and gait
  % Prepare data - for mean and peak per muscle per subject
   for i = 1:nrSbj
       Prt1_c = AllData.Cycling.Day1.Relevance_data.(char(SbjNms(i))).nanmean;
       Prt2_g = AllData.Gait.Day1.Relevance_data.(char(SbjNms(i))).nanmean;
       
        % split data per muscle
          for m = 1:8
              Correlation_Tasks.(char(SbjNms(i))).Cycling(m,1) = nanmean(Prt1_c(((m-1)*200+1):((m)*200)));
              Correlation_Tasks.(char(SbjNms(i))).Cycling(m,2) = max(Prt1_c(((m-1)*200+1):((m)*200)));
          end
          for m = 1:8
              Correlation_Tasks.(char(SbjNms(i))).Gait(m,1) = nanmean(Prt2_g(((m-1)*200+1):((m)*200)));
              Correlation_Tasks.(char(SbjNms(i))).Gait(m,2) = max(Prt2_g(((m-1)*200+1):((m)*200)));
          end
          clearvars Prt1_c Prt2_g 
   end
   tlr = 1;
   for i = 1:nrSbj
      Sctr_get_C(tlr:tlr+7,:) = Correlation_Tasks.(char(SbjNms(i))).Cycling;
      Sctr_get_G(tlr:tlr+7,:) = Correlation_Tasks.(char(SbjNms(i))).Gait;
        tlr = tlr + 8;
   end
   for m = 1:8
     tlr = 1;       
       for i = 1:nrSbj
          Sctr_get_C.(strcat('m',num2str(m)))(tlr,:) = Correlation_Tasks.(char(SbjNms(i))).Cycling(m,:);
          Sctr_get_G.(strcat('m',num2str(m)))(tlr,:) = Correlation_Tasks.(char(SbjNms(i))).Gait(m,:);
            tlr = tlr + 1;
       end   
   end

       figure
       for m = 1:8
           subplot(4,2,m)
            scatter(Sctr_get_C.(strcat('m',num2str(m)))(:,1),Sctr_get_G.(strcat('m',num2str(m)))(:,1))
              [r p] = corrcoef(Sctr_get_C(:,1),Sctr_get_G(:,1))                    
             hold on
            scatter(Sctr_get_C.(strcat('m',num2str(m)))(:,2),Sctr_get_G.(strcat('m',num2str(m)))(:,2),'r')
              [r2 p2] = corrcoef(Sctr_get_C(:,2),Sctr_get_G(:,2))   
       end


%% Circle figure for pedalling
 %%%%%%%%%%%%%%%%%%
 %%% Figure 6
 %%%%%%%%%%%%%%%%%%
  
  %%%%% !!! %%%%%
  %%% Note that the figure needs to be rotated 90 degrees to the left and
  %%% then flipped horizontally post-Matlab !
  %%%%% !!! %%%%%
  

 % Prepare data
     Sign_All_Pedal.VL = zeros(200,78);
     Sign_All_Pedal.RF = zeros(200,78);
     Sign_All_Pedal.VM = zeros(200,78);
     Sign_All_Pedal.GL = zeros(200,78);
     Sign_All_Pedal.GM = zeros(200,78);
     Sign_All_Pedal.SOL = zeros(200,78);
     Sign_All_Pedal.TA = zeros(200,78);
     Sign_All_Pedal.BF = zeros(200,78);
         
      for k = 1:78
         for m=1:8
            hold on            
                Locss = find(AllData.Cycling.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(m))) > 29)';
                 Sign_All_Pedal.(char(muscle_nms(m)))(Locss,k) = 1;
         end
      end
      for i = 1:200
        for m=1:8
            Sign_All_Pedal_sums.(char(muscle_nms(m)))(i,1) = sum(Sign_All_Pedal.(char(muscle_nms(m)))(i,:));
            mx(m,1) = max(Sign_All_Pedal_sums.(char(muscle_nms(m))))
        end
      end
      
      for m = 1:8
          if Sign_All_Pedal_sums.(char(muscle_nms(m)))(1,1) == 0
             Starts_n_Stops.(char(muscle_nms(m)))(1,:) = find(diff((Sign_All_Pedal_sums.(char(muscle_nms(m)))>0)))
               for k = 1:(length(Starts_n_Stops.(char(muscle_nms(m))))/2)
                   Starts_n_Stops.(char(muscle_nms(m)))(1,(2*k)-1) = Starts_n_Stops.(char(muscle_nms(m)))((2*k)-1) + 1
               end              
          else              
             Starts_n_Stops.(char(muscle_nms(m)))(1,1) = 0;
             nrss = find(diff((Sign_All_Pedal_sums.(char(muscle_nms(m)))>0)));
             Starts_n_Stops.(char(muscle_nms(m)))(1,2:1+length(nrss)) = find(diff((Sign_All_Pedal_sums.(char(muscle_nms(m)))>0)))
               for k = 1:(length(Starts_n_Stops.(char(muscle_nms(m))))/2)
                   Starts_n_Stops.(char(muscle_nms(m)))(1,(2*k)-1) = Starts_n_Stops.(char(muscle_nms(m)))(1,(2*k)-1) + 1
               end
          end
          if Sign_All_Pedal_sums.(char(muscle_nms(m)))(end,1) == 0
          else
             Starts_n_Stops.(char(muscle_nms(m)))(1,end+1) = 200;
          end
      end        
      
      
  % create wheel
     clearvars xunit yunit
     figure
       th = 0:pi/360:2*pi;
         for i = 1:9
            r = 500-(50*i);
            x = 0;
            y = 0;
            hold on
            xunit(i,:) = r * cos(th) + x;
            yunit(i,:) = r * sin(th) + y;
            h = plot(xunit(i,:), yunit(i,:),'k');
            clearvars r h ;
         end    
          lnV1 = length(xunit);             

         
  % Fill colorwheel
      for i = 1:8
         FillAreass = Starts_n_Stops.(char(muscle_nms(i)))  ;
          for nrrs = 1:(length(Starts_n_Stops.(char(muscle_nms(i))))/2)
              for lpke = FillAreass(1,((2*nrrs)-1)):FillAreass(1,((2*nrrs)))
                 PrtcNr = Sign_All_Pedal_sums.(char(muscle_nms(i)))(lpke,1);
                  Strt = round((lnV1/200)*(lpke-1));
                  if Strt == 0
                      Strt = 1;
                  end
                  Stp = round((lnV1/200)*(lpke))    ;  
                  

                % Fill the areas
                  if Strt<Stp
                     f1 = fill([xunit(i,Strt:Stp) flip(xunit(i+1,Strt:Stp))],[yunit(i,Strt:Stp) flip(yunit(i+1,Strt:Stp))],cbs(i,:)) ;
                       set(f1,'FaceColor',cbs(i,:),'FaceAlpha',((1/15)*PrtcNr),'EdgeColor',cbs(i,:),'EdgeAlpha',0)   % note: changing the transparacy will create mismatch between fillcolor and line color
                       % Cover up the connecting line in the same color
                         l1 = line([xunit(i,Strt) xunit(i+1,Strt)],[yunit(i,Strt) yunit(i+1,Strt)]);
                         l2 = line([xunit(i,Stp) xunit(i+1,Stp)],[yunit(i,Stp) yunit(i+1,Stp)]);
                         set(l1,'Color',cbs(i,:));
                         set(l2,'Color',cbs(i,:));                    
                  else 
                      tlr = tlr+1;
                     fill([xunit(i,1:Stp) flip(xunit(i+1,1:Stp))],[yunit(i,1:Stp) flip(yunit(i+1,1:Stp))],cbs(i,:))  ;
                     fill([xunit(i,Strt:end) flip(xunit(i+1,Strt:end))],[yunit(i,Strt:end) flip(yunit(i+1,Strt:end))],cbs(i,:))  ; 
                       Cover up the connecting line in the same color
                         l1 = line([xunit(i+1,Strt) xunit(i,Strt)],[yunit(i+1,Strt) yunit(i,Strt)]);                 
                         l2 = line([xunit(i,Stp) xunit(i+1,Stp)],[yunit(i,Stp) yunit(i+1,Stp)]);
                         l3 = line([xunit(i,end) xunit(i+1,end)],[yunit(i,end) yunit(i+1,end)]);
                         set(l1,'Color',cbs(i,:));
                         set(l2,'Color',cbs(i,:));   
                         set(l3,'Color',cbs(i,:));                      
                  end
                clearvars f1 l1 l2 l3 Strt Stp PrtcNr 
              end
              clearvars lpke
          end
              clearvars FillAreass nrrs
      end
          % Set the axes to have equal length, so that they *look* like circles
             axis equal     ;
             set(gca,'Visible','off');
             set(gcf,'Color','w');
 
  %%%%% !!! %%%%%
  %%% Note that the figure needs to be rotated 90 degrees to the left and
  %%% then flipped horizontally post-Matlab !
  %%%%% !!! %%%%% 
 
 
 
%% Circle + linear figure for gait

 % Prepare data
    clearvars Starts_n_Stops Sign_All_Gait Locss Sign_All_Gait_sums
     Sign_All_Gait.VL = zeros(200,78);
     Sign_All_Gait.RF = zeros(200,78);
     Sign_All_Gait.VM = zeros(200,78);
     Sign_All_Gait.GL = zeros(200,78);
     Sign_All_Gait.GM = zeros(200,78);
     Sign_All_Gait.SOL = zeros(200,78);
     Sign_All_Gait.TA = zeros(200,78);
     Sign_All_Gait.BF = zeros(200,78);
         
      for k = 1:78
         for m=1:8
            hold on            
                Locss = find(AllData.Gait.Day1.HighRelevanceIncidence.(char((char(SbjNms(k))))).(char(muscle_nms(m))) > 29)';
                 Sign_All_Gait.(char(muscle_nms(m)))(Locss,k) = 1;
         end
      end
      for i = 1:200
        for m=1:8
            Sign_All_Gait_sums.(char(muscle_nms(m)))(i,1) = sum(Sign_All_Gait.(char(muscle_nms(m)))(i,:));
            mx(m,1) = max(Sign_All_Gait_sums.(char(muscle_nms(m))))
        end
      end
      
      for m = 1:8
          if Sign_All_Gait_sums.(char(muscle_nms(m)))(1,1) == 0
             Starts_n_Stops.(char(muscle_nms(m)))(1,:) = find(diff((Sign_All_Gait_sums.(char(muscle_nms(m)))>0)))
               for k = 1:(length(Starts_n_Stops.(char(muscle_nms(m))))/2)
                   Starts_n_Stops.(char(muscle_nms(m)))(1,(2*k)-1) = Starts_n_Stops.(char(muscle_nms(m)))((2*k)-1) + 1
               end              
          else              
             Starts_n_Stops.(char(muscle_nms(m)))(1,1) = 0;
             nrss = find(diff((Sign_All_Gait_sums.(char(muscle_nms(m)))>0)));
             Starts_n_Stops.(char(muscle_nms(m)))(1,2:1+length(nrss)) = find(diff((Sign_All_Gait_sums.(char(muscle_nms(m)))>0)))
               for k = 1:(length(Starts_n_Stops.(char(muscle_nms(m))))/2)
                   Starts_n_Stops.(char(muscle_nms(m)))(1,(2*k)-1) = Starts_n_Stops.(char(muscle_nms(m)))(1,(2*k)-1) + 1
               end
          end
          if Sign_All_Gait_sums.(char(muscle_nms(m)))(end,1) == 0
          else
             Starts_n_Stops.(char(muscle_nms(m)))(1,end+1) = 200;
          end
      end        
      
      
  % create wheel
     clearvars xunit yunit
     figure
       th = 0:pi/360:2*pi;
         for i = 1:9
            r = 500-(50*i);
            x = 0;
            y = 0;
            hold on
            xunit(i,:) = r * cos(th) + x;
            yunit(i,:) = r * sin(th) + y;
            h = plot(xunit(i,:), yunit(i,:),'k');
            clearvars r h ;
         end    
          lnV1 = length(xunit);             

         
  % Fill colorwheel
      for i = 1:8
         FillAreass = Starts_n_Stops.(char(muscle_nms(i)))  ;
          for nrrs = 1:(length(Starts_n_Stops.(char(muscle_nms(i))))/2)
              for lpke = FillAreass(1,((2*nrrs)-1)):FillAreass(1,((2*nrrs)))
                 PrtcNr = Sign_All_Gait_sums.(char(muscle_nms(i)))(lpke,1);
                  Strt = round((lnV1/200)*(lpke-1));
                  if Strt == 0
                      Strt = 1;
                  end
                  Stp = round((lnV1/200)*(lpke))    ;  
                  

                % Fill the areas
                  if Strt<Stp
                     f1 = fill([xunit(i,Strt:Stp) flip(xunit(i+1,Strt:Stp))],[yunit(i,Strt:Stp) flip(yunit(i+1,Strt:Stp))],cbs(i,:)) ;
                       set(f1,'FaceColor',cbs(i,:),'FaceAlpha',((1/15)*PrtcNr),'EdgeColor',cbs(i,:),'EdgeAlpha',0)   % note: changing the transparacy will create mismatch between fillcolor and line color
                       % Cover up the connecting line in the same color
                         l1 = line([xunit(i,Strt) xunit(i+1,Strt)],[yunit(i,Strt) yunit(i+1,Strt)]);
                         l2 = line([xunit(i,Stp) xunit(i+1,Stp)],[yunit(i,Stp) yunit(i+1,Stp)]);
                         set(l1,'Color',cbs(i,:));
                         set(l2,'Color',cbs(i,:));                    
                  else 
                      tlr = tlr+1;
                     fill([xunit(i,1:Stp) flip(xunit(i+1,1:Stp))],[yunit(i,1:Stp) flip(yunit(i+1,1:Stp))],cbs(i,:))  ;
                     fill([xunit(i,Strt:end) flip(xunit(i+1,Strt:end))],[yunit(i,Strt:end) flip(yunit(i+1,Strt:end))],cbs(i,:))  ; 
                       Cover up the connecting line in the same color
                         l1 = line([xunit(i+1,Strt) xunit(i,Strt)],[yunit(i+1,Strt) yunit(i,Strt)]);                 
                         l2 = line([xunit(i,Stp) xunit(i+1,Stp)],[yunit(i,Stp) yunit(i+1,Stp)]);
                         l3 = line([xunit(i,end) xunit(i+1,end)],[yunit(i,end) yunit(i+1,end)]);
                         set(l1,'Color',cbs(i,:));
                         set(l2,'Color',cbs(i,:));   
                         set(l3,'Color',cbs(i,:));                      
                  end
                clearvars f1 l1 l2 l3 Strt Stp PrtcNr 
              end
              clearvars lpke
          end
              clearvars FillAreass nrrs
      end
          % Set the axes to have equal length, so that they *look* like circles
             axis equal     ;
             set(gca,'Visible','off');
             set(gcf,'Color','w');
 
  %%%%% !!! %%%%%
  %%% Note that the figure needs to be rotated 90 degrees to the left and
  %%% then flipped horizontally post-Matlab !
  %%%%% !!! %%%%%   


  
  % Linear figure
     clearvars xunit yunit
     figure
         for i = 1:9
            ht = 50;
            x = 0;
            y = 450;
            hold on
            xunit(i,:) = 1:721;
            yunit(i,1:721) = y-(ht*i);
            h = plot(xunit(i,:), yunit(i,:),'k');
            clearvars r h ;
         end    
          lnV1 = length(xunit);             

         
  % Fill bars
      for i = 1:8
         FillAreass = Starts_n_Stops.(char(muscle_nms(i)))  ;
          for nrrs = 1:(length(Starts_n_Stops.(char(muscle_nms(i))))/2)
              for lpke = FillAreass(1,((2*nrrs)-1)):FillAreass(1,((2*nrrs)))
                 PrtcNr = Sign_All_Gait_sums.(char(muscle_nms(i)))(lpke,1);
                  Strt = round((lnV1/200)*(lpke-1));
                  if Strt == 0
                      Strt = 1;
                  end
                  Stp = round((lnV1/200)*(lpke))    ;  
                  

                % Fill the areas
                  if Strt<Stp
                     f1 = fill([xunit(i,Strt:Stp) flip(xunit(i+1,Strt:Stp))],[yunit(i,Strt:Stp) flip(yunit(i+1,Strt:Stp))],cbs(i,:)) ;
                       set(f1,'FaceColor',cbs(i,:),'FaceAlpha',((1/15)*PrtcNr),'EdgeColor',cbs(i,:),'EdgeAlpha',0)   % note: changing the transparacy will create mismatch between fillcolor and line color
                       % Cover up the connecting line in the same color
                         l1 = line([xunit(i,Strt) xunit(i+1,Strt)],[yunit(i,Strt) yunit(i+1,Strt)]);
                         l2 = line([xunit(i,Stp) xunit(i+1,Stp)],[yunit(i,Stp) yunit(i+1,Stp)]);
                         set(l1,'Color',cbs(i,:));
                         set(l2,'Color',cbs(i,:));                    
                  else 
                      tlr = tlr+1;
                     fill([xunit(i,1:Stp) flip(xunit(i+1,1:Stp))],[yunit(i,1:Stp) flip(yunit(i+1,1:Stp))],cbs(i,:))  ;
                     fill([xunit(i,Strt:end) flip(xunit(i+1,Strt:end))],[yunit(i,Strt:end) flip(yunit(i+1,Strt:end))],cbs(i,:))  ; 
                       Cover up the connecting line in the same color
                         l1 = line([xunit(i+1,Strt) xunit(i,Strt)],[yunit(i+1,Strt) yunit(i,Strt)]);                 
                         l2 = line([xunit(i,Stp) xunit(i+1,Stp)],[yunit(i,Stp) yunit(i+1,Stp)]);
                         l3 = line([xunit(i,end) xunit(i+1,end)],[yunit(i,end) yunit(i+1,end)]);
                         set(l1,'Color',cbs(i,:));
                         set(l2,'Color',cbs(i,:));   
                         set(l3,'Color',cbs(i,:));                      
                  end
                clearvars f1 l1 l2 l3 Strt Stp PrtcNr 
              end
              clearvars lpke
          end
              clearvars FillAreass nrrs
      end
          % Set the axes to have equal length, so that they *look* like circles
             xlim([0 721]); 
             ylim([-10 400])
             set(gca,'Color','none','YColor','none','FontSize',16,'Xtick',[1 721],'XTicklabels',[0 100])
             set(gcf,'Color','w');
             xlabel('% gait cycle','FontSize',16)

             
 %% Compare signatures between model N78 and model N6
   % Plot signature maps for X participants Day 1 cycling and gait
       Sbjs2plot = 1;
       Sbjs_sel = [6];
       SbjNms = fieldnames(AllData.Cycling.Day1.HighRelevanceIncidence);
       Nms = {'N78'};
        figure ;
            ha = tight_subplot(Sbjs2plot*2,1,[.01 .03],[0.1 0.1],[0.1 0.1])  ;
            k = 0;
          for j = 1:Sbjs2plot
              k = k+1;
            axes(ha(k));                           
             for m=1:8
                hold on
                ylim([0 8]);
                xlim([1 200]);
                set(gcf,'Color','w');
                PlotPos = get(gca,'Position') ;
                LftCorner = [(PlotPos(1)/5) PlotPos(2)];
                    PlotWidths = PlotPos(3)/8;
                    PlotHeights = PlotPos(4)/3  ; 
                    
                    if j == 2
                      ylabel({'Pedalling',strcat('P'," - ",num2str(Sbjs_sel(j)))},'FontSize',14);
                    else
                      ylabel({strcat('N78 - P'," - ",num2str(Sbjs_sel(j)))},'FontSize',14);                        
                    end
%                     if k == Sbjs2plot
%                       xlabel('time (% of cycle)','FontSize',14);
%                     else
%     %                   set(gca,'XColor', 'none');
%                     end
                    set(gca,'YTickLabel', [])                           

                    Locss = find(AllData.Cycling.Day1.HighRelevanceIncidence.(char(['Subj' num2str(Sbjs_sel(j))])).(char(muscle_nms(m))) > 29)';
                    if isempty(Locss)==0
                        LocSplits = find(diff(Locss)>1);
                        LocsExLoc = Locss(LocSplits);
                        LocsExLoc2 = Locss(LocSplits+1);

                        xbars = zeros((length(LocSplits)+1)*2,1);
                        xbars(1,1) = Locss(1,1);
                        for tlr = 1:length(LocSplits)
                            xbars(tlr*2) = LocsExLoc(tlr);
                        end
                        for tlr = 1:length(LocSplits)
                            xbars((tlr*2)+1) = LocsExLoc2(tlr);
                        end
                        xbars(end,1) = Locss(end,1);
                    hold on;
                    yLmmx = 9-m;
                    yLmmn = 8-m ;           
                    for tlr = 1:length(LocSplits)+1
                        p1 = patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[yLmmn yLmmx yLmmx yLmmn], cbs(m,:));
                        set(p1,'FaceAlpha',1,'EdgeColor','none');
                    end      
                    end
                  VrtL2 = [-0.1:1:8.1];
                  for lpkk = 1:3
                      VrtLloc2(:,:) = zeros(length(VrtL2));
                      VrtLloc2(:,:) = 50*lpkk;              
                      plot(VrtLloc2,VrtL2,'k','LineStyle','--');   
                  end                      
                    clearvars Locss LocSplits LocsExLoc LocsExLoc2 xbars p1
             end
                  set(gca,'XTick',[]);                                  
                  set(gca,'YTick',[]);                                 
                    set(gca,'LineWidth',1.2,'YTickLabel','','FontSize',14);  
          end
          

          for j = 1:Sbjs2plot
              k = k+1;
            axes(ha(k));                           
             for m=1:8
                hold on
                ylim([0 8]);
                xlim([1 200]);
                set(gcf,'Color','w');
                PlotPos = get(gca,'Position') ;
                LftCorner = [(PlotPos(1)/5) PlotPos(2)];
                    PlotWidths = PlotPos(3)/8;
                    PlotHeights = PlotPos(4)/3  ; 
                    
                    if j == 2
                      ylabel({'Pedalling',strcat('P'," - ",num2str(Sbjs_sel(j)))},'FontSize',14);
                    else
                      ylabel({strcat('N6 - P'," - ",num2str(Sbjs_sel(j)))},'FontSize',14);                        
                    end
                    if k == Sbjs2plot
                      xlabel('time (% of cycle)','FontSize',14);
                    else
    %                   set(gca,'XColor', 'none');
                    end
                    set(gca,'YTickLabel', [])                           

                    Locss = find(AllData_N6.Cycling.Day1.HighRelevanceIncidence.(char(['Subj' num2str(Sbjs_sel(j))])).(char(muscle_nms(m))) == 1)';
                    if isempty(Locss)==0
                        LocSplits = find(diff(Locss)>1);
                        LocsExLoc = Locss(LocSplits);
                        LocsExLoc2 = Locss(LocSplits+1);

                        xbars = zeros((length(LocSplits)+1)*2,1);
                        xbars(1,1) = Locss(1,1);
                        for tlr = 1:length(LocSplits)
                            xbars(tlr*2) = LocsExLoc(tlr);
                        end
                        for tlr = 1:length(LocSplits)
                            xbars((tlr*2)+1) = LocsExLoc2(tlr);
                        end
                        xbars(end,1) = Locss(end,1);
                    hold on;
                    yLmmx = 9-m;
                    yLmmn = 8-m ;           
                    for tlr = 1:length(LocSplits)+1
                        p1 = patch([xbars((2*tlr)-1) xbars((2*tlr)-1), xbars((2*tlr)) xbars((2*tlr))],[yLmmn yLmmx yLmmx yLmmn], cbs(m,:));
                        set(p1,'FaceAlpha',1,'EdgeColor','none');
                    end      
                    end
                  VrtL2 = [-0.1:1:8.1];
                  for lpkk = 1:3
                      VrtLloc2(:,:) = zeros(length(VrtL2));
                      VrtLloc2(:,:) = 50*lpkk;              
                      plot(VrtLloc2,VrtL2,'k','LineStyle','--');   
                  end                      
                    clearvars Locss LocSplits LocsExLoc LocsExLoc2 xbars p1
             end
                  set(gca,'XTick',[]);                                  
                  set(gca,'YTick',[]);                                 
                    set(gca,'LineWidth',1.2,'YTickLabel','','FontSize',14);  
          end