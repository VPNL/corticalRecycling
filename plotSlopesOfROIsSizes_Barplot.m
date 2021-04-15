% plotSlopesROISizes_Barplot

% This script runs linear mixed models (LMM) on the size of ROIs
% and then creates a bar plot showing the slopes of LMMs.

%% set up directories and files
dataDir = './data/';
figuresDir = './figures/';
fileName = 'roiSizes_noSubjIDs.mat';

load([dataDir fileName])

%% Loop through ROIs, format data into a table and run LMM for each ROI
rois = fieldnames(roiSizes);

roisNoHemis = cellfun(@(x) extractAfter(x,'h_') , rois, 'UniformOutput', 0);
roiNames4Plotting = unique(roisNoHemis, 'stable');

modelParams = struct;

for r=1:length(rois)
    roi = rois{r};
    tbl = structureVoxelData4Table(roiSizes, roi, 'size', '');
    
    % Run LMM for this ROI and save parameters
    %modelParams = runLMM(tbl, dependentVar, predictorVar, groupingVar, roi, contrast, modelParams)
    modelParams = runLMM(tbl, 'voxelData', 'age', 'subj', roi, 'size', modelParams);
    clearvars tbl allSizes allAges
end

%% Create a bar plot with the slopes of all linear mixed models
% The bar plot should be grouped with left and right version of each ROI
% grouped together
% M groups (5) of N bars (2)
barData = [modelParams.(rois{1}).('size').slope modelParams.(rois{2}).('size').slope;...
    modelParams.(rois{3}).('size').slope modelParams.(rois{4}).('size').slope;...
    modelParams.(rois{5}).('size').slope modelParams.(rois{6}).('size').slope;...
    modelParams.(rois{7}).('size').slope modelParams.(rois{8}).('size').slope;...
    modelParams.(rois{9}).('size').slope modelParams.(rois{10}).('size').slope];

g=[repmat({'lh'},length(rois)/2, 1) repmat({'rh'},length(rois)/2, 1)];

% Create figure
figure(1)
set(gcf, 'Position', [0 0 700 600])
b = bar(barData, 'FaceColor','flat','EdgeColor','none',  'BarWidth',0.90);
hold on
%% Color bars by ROI and hemisphere
b(1).CData(1,:) = [133/255 193/255 233/255];
b(1).CData(2,:) = [133/255 193/255 233/255];
b(1).CData(3,:) = [255/255 235/255 59/255]; 
b(1).CData(4,:) = [146/255 43/255 33/255];
b(1).CData(5,:) = [146/255 43/255 33/255];

b(2).CData(1,:) = [133/255 193/255 233/255];
b(2).CData(2,:) = [133/255 193/255 233/255];
b(2).CData(3,:) = [255/255 235/255 59/255]; 
b(2).CData(4,:) = [146/255 43/255 33/255];
b(2).CData(5,:) = [146/255 43/255 33/255];

% b(2).EdgeColor = [0.7 0.7 0.7];
% b(1).EdgeColor = [0 0 0]; 
% b(1).LineWidth = 2.5;
% b(2).LineWidth = 2.5;

%% Add errorbars to plot
ngroups = size(barData, 1);
nbars = size(barData, 2);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    
    % Plot left hemisphere ROIs on the left and right-hemi-ROIs on the right
    if i==1
        hemi = 'lh';
    elseif i==2
        hemi = 'rh';      
    end
    
    for xl = 1:length(x)
        eb = plot([x(xl) x(xl)], [modelParams.([hemi '_' roiNames4Plotting{xl}]).('size').slope_lower modelParams.([ hemi '_' roiNames4Plotting{xl}]).('size').slope_upper]);
        eb.LineWidth = 2;
        eb.Color = [0.6 0.6 0.6];
    end
end


%% Format axes
xticks([1 2 3 4 5])
xticklabels(roiNames4Plotting)
ylabel('ROI size (mm^3)')
xtickangle(30) 
set(gca, 'YTick', [-2 -1 0 1 2 3])
set(gca,'YTicklabel', [-2 -1 0 1 2 3],'FontSize',20 )
set(gca,'TickLabelInterpreter','none')
ylabel({'Change in volume (mm^3/month)'}, 'FontSize', 15)
title('Development of ROI sizes')
box off
ylim([-3.5 3.5])

% save plot
figureName = 'ChangeInROISizes_Barplot';
print(fullfile(figuresDir, figureName), '-dpng', '-r200')


