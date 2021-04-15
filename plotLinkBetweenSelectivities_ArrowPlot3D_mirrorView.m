% DESCRIPTION: This script runs a linear mixed model between the
% selectivity to faces, words, and limbs in difference-ROIs, and plots
% the model prediction as well as individual dataSelectVoxels in a 3D plot.

%% Set up Data directories and select which ROI to plot
dataDir = './data/';
fileName = 'selectiveVoxels_allSubjects_diff_noIDs';
figuresDir = './figures/';

load([dataDir fileName])

% (1) Select one emerging or waning ROIs out of the following:
% ROIs = {'lh_pOTS_word_initialEndDiffDomainDep', 'lh_OTS_limb_initialEndDiffDomainDep', ...
% 'rh_OTS_limb_initialEndDiffDomainDep',...
% 'lh_pFus_faceadultfacechild_initialEndDiffDomainDep',...
% 'rh_pFus_faceadultfacechild_initialEndDiffDomainDep'}

 roi ='lh_pOTS_word_initialEndDiffDomainDep';
 
 % (2) Select an angle: we can create the same plot in mirrored views. 
 % Select either 20 or 110, for example: plotAngle=20;
 
plotAngle=110;

%% Select dataSelectVoxels for table
subjects = fieldnames(dataSelectVoxels.(roi));
sessions = [];
faces= [];
limbs= [];
words= [];
age = [];
subj ={};
sessNames ={};
modelParams = struct;

for s=1:length(subjects)
    subject=subjects{s};
    sessions = fieldnames(dataSelectVoxels.(roi).(subject));

    for ses=1:length(sessions)
        faces(end+1,1)= dataSelectVoxels.(roi).(subject).(sessions{ses}).('meanFaces');
        limbs(end+1,1)= dataSelectVoxels.(roi).(subject).(sessions{ses}).('meanLimbs');
        words(end+1,1)= dataSelectVoxels.(roi).(subject).(sessions{ses}).('meanWords');
        age(end+1,1)= dataSelectVoxels.(roi).(subject).(sessions{ses}).age;
        subj{end+1,1} =subject;
        sessNames{end+1,1} = sessions{ses};
    end

end

% Combine the data into a table to run a LMM
tbl= table(faces, limbs, words, age, subj, sessNames);

% Predictor and dependent Variables differ by ROI. The dependent Variable is
% the ROI-defining category, the other two are predictor Variables.

if contains(roi, 'word')
    dependentVar = 'words';
    predictorVar1 = 'limbs';
    predictorVar2 = 'faces';
    
elseif contains(roi, 'face')
    dependentVar = 'faces';
    predictorVar1 = 'limbs';
    predictorVar2 = 'words';
    
elseif contains(roi, 'limb')
    dependentVar = 'limbs';
    predictorVar1 = 'faces';
    predictorVar2 = 'words';
end
groupingVar = 'subj';

% Run LMM and save parameters
modelParams =runLMMMultPredictors(tbl, dependentVar, predictorVar1, predictorVar2, groupingVar, roi, modelParams);

%% Create a 3D Arrow Plot
figure(1)
set(gcf, 'Position', [0 0 710 600]);
%% Axes
% We need a larger axis range for the right hemisphere
if contains(roi, 'rh_')
    axis([-6,8,-8,6,-2,9])
else
    axis([-6,6,-8,6,-2,7.6])
end

xticks([-6, -3, 0, 3, 6])
xticklabels({ '-6', '-3', '0', '3', '6', })
yticks([-6, -3, 0, 3, 6])
yticklabels({ '-6', '-3', '0', '3', '6'})
zticks([0, 3, 6,])
zticklabels({ '0', '3', '6' })

hold on;

pbaspect([1 1 1])
grid on

view(plotAngle, 15)

%% Add planes and further formatting
 % Indicate quadrants visually
 if contains(roi, 'lh')
    q1 = surf(  [-6 -6; 0 0], [-8 0; -8 0], [0 0; 0 0], 'FaceColor', [0.7 0.7 0.7], 'edgecolor','k', 'FaceAlpha', 0.6); 
    q2 = surf(  [-6 -6; 0 0], [6 0; 6 0], [0 0; 0 0], 'FaceColor', [0.7 0.7 0.7], 'edgecolor', 'k','FaceAlpha', 0.6 ); 
    q3 = surf(  [6 6; 0 0], [-8 0; -8 0], [0 0; 0 0], 'FaceColor', [0.7 0.7 0.7], 'edgecolor','k', 'FaceAlpha', 0.6); 
    q4 = surf(  [6 6; 0 0], [6 0; 6 0], [0 0; 0 0], 'FaceColor', [0.7 0.7 0.7], 'edgecolor','k', 'FaceAlpha', 0.6); 
 else
    q1 = surf(  [-6 -6; 0 0], [-8 0; -8 0], [0 0; 0 0], 'FaceColor', [0.7 0.7 0.7] ,'edgecolor','k', 'FaceAlpha', 0.6); 
    q2 = surf(  [-6 -6; 0 0], [6 0; 6 0], [0 0; 0 0], 'FaceColor', [0.7 0.7 0.7],'edgecolor', 'k', 'FaceAlpha', 0.6); 
    q3 = surf(  [8 8; 0 0], [-8 0; -8 0], [0 0; 0 0], 'FaceColor', [0.7 0.7 0.7], 'edgecolor','k', 'FaceAlpha', 0.6); 
    q4 = surf(  [8 8; 0 0], [6 0;6 0], [0 0; 0 0], 'FaceColor', [0.7 0.7 0.7], 'edgecolor','k', 'FaceAlpha', 0.6); 
 end

% Format lines
q1.LineWidth = 3;
q2.LineWidth = 3;
q3.LineWidth = 3;
q4.LineWidth = 3;

% Color Y Plane blue   
if plotAngle == 110;
    surf(  [-10 -10; 10 10], [0 0; 0 0], [-10 10; -10 10],'FaceColor',  [0.0 0.3 0.8],'edgecolor','none', 'FaceAlpha', 0.55);
elseif plotAngle == 20;
    surf(  [0 0; 0 0], [-10 -10; 10 10], [-10 10; -10 10],'FaceColor',  [0.0 0.3 0.8],'edgecolor','none', 'FaceAlpha', 0.55);
end


% Axes labelling
ax = get(gca, 'YTickLabel');
set(gca, 'YTickLabel', ax, 'FontSize', 28)
axx = get(gca, 'XTickLabel');
set(gca, 'XTickLabel', axx, 'FontSize', 28)

axz = get(gca, 'ZTickLabel');
set(gca, 'ZTickLabel', axz, 'FontSize', 28)
set(gca, 'LineWidth', 2)

light('position',[-6 -8 9],'style','local')

%% Plot individual subject data as arrows
subjUnique = unique(tbl.subj, 'stable');

for su= 1:length(subjUnique)

    currentSubj = subjUnique{su};
    
    % dependent Var Values
    colIndexdependentVarData = find(strcmp(tbl.Properties.VariableNames, dependentVar), 1);
    dependentVarVals = tbl{strcmp(tbl.subj,currentSubj), colIndexdependentVarData};
    
    % Predictor 1 
    colIndexPred1Data = find(strcmp(tbl.Properties.VariableNames, predictorVar1), 1);
    pred1Vals = tbl{strcmp(tbl.subj,currentSubj), colIndexPred1Data};
    
    % Predictor 2 
    colIndexPred2Data = find(strcmp(tbl.Properties.VariableNames, predictorVar2), 1);
    pred2Vals = tbl{strcmp(tbl.subj,currentSubj), colIndexPred2Data};
    pbaspect([1 1 1])
    arrow3([pred1Vals(1) pred2Vals(1) dependentVarVals(1)],[pred1Vals(end) pred2Vals(end) dependentVarVals(end)],...
        'q2.5',3,2.2, [], 0.9)
    hold on
    
    clearvars dependentVarVals pred1Vals pred2Vals
end

%% Add model Prediction arrrow
% Plot a model reflecting the model fit. This arrow predcits the values of
% the dependdent variable bassed on the mean values of predictor 1 and 2 for
% young kids (5-9yo) and teens (13-17yo)

[youngKidsSelected, youngKidsAgesSelected, youngKidsSessionsSelected,...
    teensSelected, teensAgesSelected, teensSessionsSelected]= selectData2AgeGroups(dataSelectVoxels, roi);

pred1ValsYoung = [];
pred2ValsYoung = [];

for y=1:length(youngKidsSelected)
    pred1ValsYoung(y) = tbl{strcmp(tbl.subj,youngKidsSelected(y))& strcmp(tbl.sessNames,youngKidsSessionsSelected(y)), colIndexPred1Data};
    pred2ValsYoung(y) = tbl{strcmp(tbl.subj,youngKidsSelected(y))& strcmp(tbl.sessNames,youngKidsSessionsSelected(y)), colIndexPred2Data};
end

pred1ValsTeens = [];
pred2ValsTeens = [];

for t=1:length(teensSelected)
    pred1ValsTeens(t) = tbl{strcmp(tbl.subj,teensSelected(t))& strcmp(tbl.sessNames,teensSessionsSelected(t)), colIndexPred1Data};
    pred2ValsTeens(t) = tbl{strcmp(tbl.subj,teensSelected(t))& strcmp(tbl.sessNames,teensSessionsSelected(t)), colIndexPred2Data};
end

arrowStartPrediction = modelParams.(roi).intcpt + modelParams.(roi).(predictorVar1)*(nanmean(pred1ValsYoung))...
    + modelParams.(roi).(predictorVar2)*(nanmean(pred2ValsYoung));

arrowHeadPrediction = modelParams.(roi).intcpt + modelParams.(roi).(predictorVar1) *(nanmean(pred1ValsTeens))...
    + modelParams.(roi).(predictorVar2) * (nanmean(pred2ValsTeens));

pbaspect([1 1 1])
arrow3([nanmean(pred1ValsYoung) nanmean(pred2ValsYoung) arrowStartPrediction],...
    [nanmean(pred1ValsTeens) nanmean(pred2ValsTeens) arrowHeadPrediction],...
        'b4',3,3,[], 0.8, 0.8)



%% ADDITIONAL FORMATTING: labels and light
xlabel([predictorVar1 ' (t)'], 'Fontsize', 18)
ylabel([predictorVar2 ' (t)'], 'Fontsize', 18)
zlabel([dependentVar ' (t)'], 'Fontsize', 18)

%Align axislabels with axes
if plotAngle==20
    xh = get(gca,'XLabel'); % Handle of the y label
    set(xh, 'Units', 'Normalized')
    pos = get(xh, 'Position');
    set(xh, 'Position',pos.*[1,1,1],'Rotation',-3)

    yh = get(gca,'YLabel'); % Handle of the y label
    set(yh, 'Units', 'Normalized')
    pos = get(yh, 'Position');
    set(yh, 'Position',pos.*[1,1,1],'Rotation',41)
else
    
end

% % title, light
if contains(roi, 'limb')
   titleStr = sprintf('Waning %s', extractBefore(roi, '_initial')); 
else
    titleStr = sprintf('Emerging %s', extractBefore(roi, '_initial'));
end

title(titleStr, 'Interpreter', 'none', 'FontSize', 11)


% save figure
figureName = sprintf('ArrowPlot_3D_%s_%d_angle', roi, plotAngle);
print(fullfile(figuresDir, figureName), '-dpng', '-r200')


