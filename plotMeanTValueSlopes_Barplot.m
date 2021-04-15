% plotMeanTValueSlopes_Barplot

% DESCRIPTION: Plots bar plots for linear mixed models indicating the
% change in mean selectivity by age in emerging and waning ROIs.

dataDir = './data/';
figuresDir = './figures/';
fileName = 'selectiveVoxels_allSubjects_diff_noIDs.mat';

load([dataDir fileName])

%% List contrasts
% Contrasts in the order we would like to plot them
contrasts = { 'Number','Words', 'Limbs', 'NoHeadBody',...
    'AdultFaces', 'ChildFaces'}; 
            
contrastNames = { 'Numbers','Words', 'Limbs', 'Bodies',...
    'Adult Faces', 'Child Faces'};     

%% Structure data for each ROI and run LMM

rois = fieldnames(dataSelectVoxels);
modelParams = struct;

for r=1:length(rois)
    roi = rois{r};
   for c=1:length(contrasts)
      contrast = contrasts{c};
      % structure Data into table format to prepare for LMM
      % tbl = structureVoxelData4Table(data, roi, metric, contrast)     
      tbl = structureVoxelData4Table(dataSelectVoxels, roi, 'mean', contrast);
      
      % run LMM
      % modelParams = runLMM(tbl, dependentVar, predictorVar, groupingVar, roi, contrast, modelParams)
      modelParams = runLMM(tbl, 'voxelData', 'age', 'subj', roi, contrast, modelParams);
       
   end
   
   %% Create a figure for each ROI
   figure(r)
   set(gcf, 'Position', [0 0 600 600]);
   
   % Set colors for barplot
   mycolors = [121/255 134/255 203/255;... % number
        133/255 193/255 233/255; ...% word 
        255/255 235/255 59/255;... % limb
        240/255 178/255 122/255 ; ...% bodies
        236/255 112/255 99/255;... % adult faces
        146/255 43/255 33/255]; % kid face
    
   for cp=1:length(contrasts)
       bar(cp, [modelParams.(roi).(contrasts{cp}).slope], 'FaceColor', mycolors(cp, :), 'EdgeColor', mycolors(cp, :), 'BarWidth', 0.9 )
       hold on
       eb = plot([cp cp], [modelParams.(roi).(contrasts{cp}).slope_lower modelParams.(roi).(contrasts{cp}).slope_upper]);
       eb.Color = [0.6 0.6 0.6];
       eb.LineWidth = 3;
   end
   
   %% Format axes
    ylim([-0.042 0.037])
    yticks([-0.03 -0.02 -0.01 0 0.01 0.02 0.03])
    yticklabels({'-0.03', '-0.02', '-0.01' '0', '0.01', '0.02', '0.03'})
    ax = get(gca, 'YTickLabel');
    set(gca, 'YTickLabel', ax, 'FontSize', 18)
    ylabel({'Change in selectivity (t/month)'},  'FontSize', 16)
    set(gca, 'LineWidth', 3) 
    xticks([1 2 3 4 5 6])
    set(gca,'XTickLabel',  contrastNames, 'FontSize', 18)
    xtickangle(30)
    box off
    
    % add title
    if contains(roi, 'limb')
        titleStr = sprintf('Waning %s', (extractBefore(roi, '_initial')));
    else
        titleStr = sprintf('Emerging %s', (extractBefore(roi, '_initial')));
    end
    title(titleStr, 'Interpreter', 'none')
    
   figureName = sprintf('BarPlot_MeanSelectivity_%s', roi);
   print(fullfile(figuresDir, figureName), '-dpng', '-r200')
   % end ROI loop
end

