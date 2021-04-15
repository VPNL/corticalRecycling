% DESCRIPTION: This script runs a linear mixed model between the
% selectivity to faces, words, and limbs in difference-ROIs, and plots
% the model prediction in a 2d bubble plot.

%% Set up Data directories and select which ROI to plot
dataDir = './data/';
fileName = 'selectiveVoxels_allSubjects_diff_noIDs';
figuresDir = './figures/';

load([dataDir fileName])

% Select one emerging or waning ROIs out of the following:

% ROIs = {'lh_pOTS_word_initialEndDiffDomainDep', 'lh_OTS_limb_initialEndDiffDomainDep', ...
% 'rh_OTS_limb_initialEndDiffDomainDep',...
% 'lh_pFus_faceadultfacechild_initialEndDiffDomainDep',...
% 'rh_pFus_faceadultfacechild_initialEndDiffDomainDep'}

roi = 'lh_pOTS_word_initialEndDiffDomainDep';
dataType = 'model';

%% Prepare data for table
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

% Combine the dataSelectVoxels into a table to run a LMM
tbl= table(faces, limbs, words, age, subj, sessNames);

% Predictor and dependent Variables differ by ROI. The dependent Variable is
% the defining selectivity, the other two are predictor Variables.

if contains(roi, 'word')
    dependentVar = 'words';
    predictorVar1 = 'faces';
    predictorVar2 = 'limbs';
    
elseif contains(roi, 'face')
    dependentVar = 'faces';
    predictorVar1 = 'words';
    predictorVar2 = 'limbs';
    
elseif contains(roi, 'limb')
    dependentVar = 'limbs';
    predictorVar1 = 'faces';
    predictorVar2 = 'words';
end
groupingVar = 'subj';

% Run LMM and save parameters
modelParams =runLMMMultPredictors(tbl, dependentVar, predictorVar1, predictorVar2, groupingVar, roi, modelParams);

%% Create a 2D Arrow- Bubble Plot
figure(1)
set(gcf, 'Position', [0 0 800 500]);

%% Axes
axis([-4,4,-4,4])
xticks([ -4,  0,4])
xticklabels({'-4', '0', '4' })
yticks([ -4, 0, 4])
yticklabels({ '-4', '0', '4'})
hold on
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',a,'fontsize',27)

r1 = refline([0 0]);
r1.Color = 'k';
r1.LineWidth = 2;
pl2 = plot([0 0], ylim, 'k');
hold on;
pl2.LineWidth = 2;
box on

%% colors
colorsPos = cbrewer('seq', 'Reds', 5); 


colIndexdependentVarData = find(strcmp(tbl.Properties.VariableNames, dependentVar), 1);
colIndexPred1Data = find(strcmp(tbl.Properties.VariableNames, predictorVar1), 1);
colIndexPred2Data = find(strcmp(tbl.Properties.VariableNames, predictorVar2), 1);
        
        

 %% model Prediction arrrow
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

%% Plot Arrow and bubbles
arrowStartPrediction = modelParams.(roi).intcpt + modelParams.(roi).(predictorVar1)*(nanmean(pred1ValsYoung))...
    + modelParams.(roi).(predictorVar2)*(nanmean(pred2ValsYoung));

arrowHeadPrediction = modelParams.(roi).intcpt + modelParams.(roi).(predictorVar1) *(nanmean(pred1ValsTeens))...
    + modelParams.(roi).(predictorVar2) * (nanmean(pred2ValsTeens));

%  Prediction young kids
scatter( nanmean(pred1ValsYoung), nanmean(pred2ValsYoung), arrowStartPrediction*320, colorsPos((floor(arrowStartPrediction*2)/2)+((floor(arrowStartPrediction*2)/2)-3) ,:), 'filled')
hold on

% %  Prediction teens
scatter( nanmean(pred1ValsTeens), nanmean(pred2ValsTeens), arrowHeadPrediction*320, colorsPos( (floor(arrowHeadPrediction*2)/2)+((floor(arrowHeadPrediction*2)/2)-3),:), 'filled')

% plot arrow indicating direction of age
daspect([1 1 1])
arrow3([nanmean(pred1ValsYoung) nanmean(pred2ValsYoung) ],...
    [nanmean(pred1ValsTeens) nanmean(pred2ValsTeens)], 'b4',3,3,[], 0.9, 0.3)


%% Format colorbar
caxis([1 6])
colormap(colorsPos)
cb = colorbar;
cb.Box = 'off';
cb.Ticks = [ 1 2 3 4 5 6];
cb.TickLabels = {'2', '2.5','3', '3.5', '4', '4.5'};
colorbarString = sprintf('%s-selectivity (t)', dependentVar(1:end-1) );
cb.Label.String = colorbarString;
cb.Label.FontSize = 26;

%% ADDITIONAL FORMATTING: axis-labels and title
xlabel([predictorVar1(1:end-1) '-selectivity (t)'], 'Fontsize', 26, 'FontName', 'Helvetica-Narrow')
ylabel([predictorVar2(1:end-1) '-selectivity (t)'], 'Fontsize', 26)

roiNoEnding = extractBefore(roi, '_initial');
roiStr = strrep(roiNoEnding, '_', ' ');

% title
if contains(roi, 'limb')
   titleStr = sprintf('Waning %s', roiStr); 
else
    titleStr = sprintf('Emerging %s', roiStr);
end
title(titleStr, 'Interpreter', 'none', 'FontSize', 11)

set(findall(gcf, 'property', 'FontName'), 'FontName', 'Helvetica-Narrow')

%% save figure
figureName = sprintf('BubblePlot2D_%s_%s', roi, dataType);
print(fullfile(figuresDir, figureName), '-dpng', '-r200')


