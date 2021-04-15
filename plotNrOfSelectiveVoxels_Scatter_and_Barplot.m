% This script runs linear mixed models on the number of selective Voxels in
% VTC ROIs. Two kinds of plots are created:

% 1.) Scatterplots showing the number of selective voxels for a given
% contrast as a function of age.
% 2.) A Bar plot summarizing the slopes of all linear mixed models.

%% Set up paths and files
dataDir = './data/';
figuresDir = './figures/';
fileName = 'selectiveVoxels_allSubjects_VTC_noIDs.mat';

% Indicate 'lateral' or 'medial' to plot either lateral or medial VTC data
partition = 'lateral';

load([dataDir fileName])
hemis = {['lh_vtc_' partition], ['rh_vtc_' partition]};

%% List contrasts
% Contrasts in the order we would like to plot them
contrasts = { 'Number','Words', 'Limbs', 'NoHeadBody', 'AdultFaces', 'ChildFaces',  ...
                'Cars', 'Guitars', 'Houses', 'Corridors'}; 
            
contrastNames = { 'Numbers','Words', 'Limbs', 'Bodies', 'Adult Faces', 'Child Faces',  ...
                'Cars', 'String instruments', 'Houses', 'Corridors'};            
            
%% Loop through ROIs and contrasts
modelParams = struct;

for h= 1:length(hemis)
    hemi = hemis{h};
    
    for c=1:length(contrasts)
        contrast= contrasts{c};
        % structure data into table format to prepare for LMM
        tbl = structureVoxelData4Table(dataSelectVoxels, hemi, 'nr', contrast);
        
        % run LMM
        modelParams = runLMM(tbl, 'voxelData', 'age', 'subj', hemi, contrast, modelParams);
        
        %% Create a scatter plot for this contrast and ROI
        figure(1)
        
        % Create CI for slope matching those produced in R
        tblnew = table();
        age_r = [60 220];
        tblnew.age=linspace(age_r(1),age_r(2))';
        tblnew.subj = repmat({'a'},100,1);
        [ypred, yCI, DF] = predict(modelParams.(hemi).(contrast).lme, tblnew);    
        
        yfit_meanline = polyval([modelParams.(hemi).(contrast).slope modelParams.(hemi).(contrast).intcpt], age_r);  
        eb = errorbar3(tblnew.age', ypred', [yCI(:,1)'; yCI(:,2)'] , 1, [0.8 0.8 0.8]);
        hold on
        
        % Plot sessions belonging to same subject in unique color
        allsubj = unique(tbl.subj, 'stable');
        colors1 = cbrewer('div', 'PuOr', 10);        
        colors2 = cbrewer('div', 'PiYG', 10);   
        colors3 = cbrewer('div', 'RdBu', 9);
        colors = [colors1; colors2; colors3];
        
        %% Add individual data to plot 
        for as=1:length(allsubj)
            ageVals = [];
            voxelVals =  [];
            currentSubj = allsubj{as};
            
            colIndexVoxelData = find(strcmp(tbl.Properties.VariableNames, 'voxelData'), 1);
            voxelVals = tbl{strcmp(tbl.subj,currentSubj), colIndexVoxelData};

            colIndexAgeData = find(strcmp(tbl.Properties.VariableNames, 'age'), 1);
            ageVals = tbl{strcmp(tbl.subj,currentSubj), colIndexAgeData};

            plot(ageVals, voxelVals, 'o', 'MarkerFaceColor', colors(as,:), 'MarkerEdgeColor', colors(as, :))

            clearvars ageVals voxelVals currentSubj
        end
        
        %% Add overall regression line, and zero line
        r= refline(modelParams.(hemi).(contrast).slope, modelParams.(hemi).(contrast).intcpt);
        r.Color = 'r';
        r.LineWidth = 4;

        % Add  zero line
        z = refline([0 0]);
        z.Color = [0 0 0];
        
        %% Format axes, title
        set(gca, 'YTick', [0 1000 2000 3000])
        set(gca,'YTicklabel', [0 1000 2000 3000],'FontSize',18 )
        ylim([-100 3000])
        ylabel({'Volume of selective'; 'activation (mm^3)'})
        
        xlim([4.2*12 18*12])
        xlabel({'age (years)'})
        set(gca,'XTick', [12*5 12*9 12*13 12*17]) 
        set(gca,'XTicklabel', [5 9 13 17],'FontSize',18 )
        
        % add title
        set(gca,'TickLength', [0 0.0]);
        currentROINoUnderscore = strrep(hemi, '_', ' ');
        titlestr = sprintf('%s (%s)', contrastNames{c}, currentROINoUnderscore);
        title(titlestr, 'Interpreter', 'none', 'FontSize',17)

        %remove box outline
        box off
        
        %% save figure
        figureName = sprintf('ScatterPlot_SelectiveVoxels_%s_%s', hemi, contrast);
        print(fullfile(figuresDir, figureName), '-dpng', '-r200')
        
        clearvars tbl sessNames voxelData age subj
        clf
        
        
    end
   % end of hemi loop 
end

%% Create a bar plot of the slopes of LMM for all contrasts in both hemispheres

figure(2)
set(gcf, 'Position', [0 0 1200 600]);

barData = [modelParams.(hemis{1}).(contrasts{1}).slope modelParams.(hemis{2}).(contrasts{1}).slope;...
    modelParams.(hemis{1}).(contrasts{2}).slope modelParams.(hemis{2}).(contrasts{2}).slope;...
    modelParams.(hemis{1}).(contrasts{3}).slope modelParams.(hemis{2}).(contrasts{3}).slope;...
    modelParams.(hemis{1}).(contrasts{4}).slope modelParams.(hemis{2}).(contrasts{4}).slope;...
    modelParams.(hemis{1}).(contrasts{5}).slope modelParams.(hemis{2}).(contrasts{5}).slope;...
    modelParams.(hemis{1}).(contrasts{6}).slope modelParams.(hemis{2}).(contrasts{6}).slope;...
    modelParams.(hemis{1}).(contrasts{7}).slope modelParams.(hemis{2}).(contrasts{7}).slope;...
    modelParams.(hemis{1}).(contrasts{8}).slope modelParams.(hemis{2}).(contrasts{8}).slope;...
    modelParams.(hemis{1}).(contrasts{9}).slope modelParams.(hemis{2}).(contrasts{9}).slope;...
    modelParams.(hemis{1}).(contrasts{10}).slope modelParams.(hemis{2}).(contrasts{10}).slope];

b=bar(barData,'FaceColor','flat', 'EdgeColor', 'none', 'BarWidth',0.9);

%% Format colors
b(1).CData(1,:) = [121/255 134/255 203/255]; % num
b(1).CData(2,:) = [133/255 193/255 233/255 ]; % word
b(1).CData(3,:) = [255/255 235/255 59/255]; % limb
b(1).CData(4,:) = [240/255 178/255 122/255 ]; % bodies
b(1).CData(5,:) = [236/255 112/255 99/255]; % adult faces
b(1).CData(6,:) = [146/255 43/255 33/255]; % kid faces
b(1).CData(7,:) = [153/255 0/255 255/255];
b(1).CData(8,:) = [255/255 152/255 255/255];
b(1).CData(9,:) = [156/255 204/255 101/255];
b(1).CData(10,:) = [0/255 105/255 92/255];

b(2).CData(1,:) = [121/255 134/255 203/255]; % num
b(2).CData(2,:) = [133/255 193/255 233/255 ]; % word
b(2).CData(3,:) = [255/255 235/255 59/255]; % limb
b(2).CData(4,:) = [240/255 178/255 122/255 ]; % bodies
b(2).CData(5,:) = [236/255 112/255 99/255]; % adult faces
b(2).CData(6,:) = [146/255 43/255 33/255]; % kid faces
b(2).CData(7,:) = [153/255 0/255 255/255];
b(2).CData(8,:) = [255/255 152/255 255/255];
b(2).CData(9,:) = [156/255 204/255 101/255];
b(2).CData(10,:) = [0/255 105/255 92/255];

hold on

%% Add errorbars to plot
ngroups = size(barData, 1);
nbars = size(barData, 2);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
 
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    for nc=1:length(x) 
        pl=plot([x(nc) x(nc)], [modelParams.(hemis{i}).(contrasts{nc}).slope_lower modelParams.(hemis{i}).(contrasts{nc}).slope_upper]);
        % color errorbars 
        pl.Color = [0.5 0.5 0.5];
        pl.LineWidth = 3;
    end
end


%% Format axes, title and save figure
ylabel({'Change in volume (mm^3/month)'}, 'FontSize',19)
yticks([-8 -6 -4 -2 0 2 4 6 8 10])
set(gca,'YTickLabel',{-8 -6 -4 -2 0 2 4 6 8 10}, 'FontSize',19)
ylim([-8 10])

xticks([1 2 3 4 5 6 7 8 9 10])
set(gca,'XTickLabel',  contrastNames, 'FontSize',19)
set(gca,'TickLabelInterpreter','none')
xtickangle(30)
ax = gca;
ax.TickLength = [0.001 0.035];

% title
titlestr = sprintf('%s VTC', partition);
title(titlestr, 'Interpreter', 'none')
box off

% Save figure
figureNameBarPlot = sprintf('BarPlot_Slopes_%s_VTC', partition);
print(fullfile(figuresDir, figureNameBarPlot),'-dpng', '-r200')

% Save Model Parameters for further plotting
modelParamsFileName = sprintf('modelParameters_%s', partition);
save(fullfile(dataDir,modelParamsFileName), 'modelParams')

