% This script plots boxPlots of the number of selective Voxels for
% different categories in VTC for young children (5-9yo) and teens
% (13-17yo).

%% Set up paths and fileNames
dataDir = './data/';
figuresDir = './figures/';
fileName = 'selectiveVoxels_allSubjects_VTC_noIDs.mat';

% Indicate 'lateral' or 'medial' to plot either lateral or medial VTC data
partition = 'lateral';

% Indicate eihter 'lh' or'rh'
hemi = 'lh';

load([dataDir fileName])
roi = [hemi '_vtc_' partition];

% Load model parameters to plot model prediction on top of boxplots
modelParamsFileName = sprintf('modelParameters_%s.mat', partition);
load([dataDir modelParamsFileName])

contrasts = { 'Number','Words', 'Limbs', 'NoHeadBody', ...
    'AdultFaces', 'ChildFaces'}; 
contrastNames = { 'N','W', 'L', 'B', ...
    'AF', 'CF'}; 


%% Select data for 5-9 year olds and 13-17yo

[youngKidsSelected, youngKidsAgesSelected, youngKidsSessionsSelected,...
    teensSelected, teensAgesSelected, teensSessionsSelected]= selectData2AgeGroups(dataSelectVoxels, roi);


%% Create Boxplots for the selected samples
figure(1)
set(gcf, 'Position', [0 0 1000 600])

% set up colors
colorsYoung = [121/255 134/255 203/255;... % number
    133/255 193/255 233/255; ...% word
    255/255 235/255 59/255;... % limb
    240/255 178/255 122/255 ; ...%bodies
    236/255 112/255 99/255;... % adult faces
    146/255 43/255 33/255];% kid faces

colorsTeens = [57/255 73/255 171/255;... % num
    52/255 152/255 219/255 ;... % word
    251/255 192/255 45/255;... % limb
    230/255 126/255 34/255 ;... %  %bodies
    203/255 67/255 53/255;... % adult faces
    100/255 30/255 22/255 ];% kid faces


%% Loop throguh contrasts
for c=1:length(contrasts)
    subplot(1,length(contrasts), c)
    contrast = contrasts{c};
    dataYoung = [];
    dataTeens = [];
    
    % Get young childrens data for this contrast
    for y=1:length(youngKidsSelected)
        dataYoung(end+1)=dataSelectVoxels.(roi).(youngKidsSelected{y}).(youngKidsSessionsSelected{y}).(['nr' contrast]);
    end
    
    % Get teen data for this contrast
    for t=1:length(teensSelected)
        dataTeens(end+1) = dataSelectVoxels.(roi).(teensSelected{t}).(teensSessionsSelected{t}).(['nr' contrast]);
    end

    g = [repmat({'5-9'}, 1, length(youngKidsSelected)), repmat({'13-17'}, 1, length(teensSelected)) ];
    boxplotData = [dataYoung, dataTeens];
    bp =boxplot(boxplotData, g,'Widths', 1 );
    hold on
    
    % Color boxplot
    b = findobj(gca,'Tag','Box');
    patch(get(b(2),'XData'),get(b(2),'YData'), colorsYoung(c, :), 'FaceAlpha',.75 ); 
    patch(get(b(1),'XData'),get(b(1),'YData'), colorsTeens(c, :), 'FaceAlpha',.75 );
    
    % change lines in Boxplot to be more visible
    gcf = formatBoxPlotLines(gcf, bp);
    
    % add model prediction for mean age of age group as diamond on the
    % boxplot
    meanAgeYoungYears = mean(floor(youngKidsAgesSelected./12));
    meanAgeTeensYears = mean(floor(teensAgesSelected./12));
    predictionYoung = modelParams.(roi).(contrast).intcpt + modelParams.(roi).(contrast).slope * (meanAgeYoungYears*12);
    predictionTeens = modelParams.(roi).(contrast).intcpt + modelParams.(roi).(contrast).slope * (meanAgeTeensYears*12);
    
    plot(1, predictionYoung, 'dk', 'MarkerFaceColor', 'k', 'MarkerSize', 12)
    plot(2, predictionTeens, 'dk', 'MarkerFaceColor', 'k', 'MarkerSize', 12)
    
    if c ~= 1
        set(gca, 'YColor', [1 1 1])
    end
    %   Plot y axis only for first subplot  
    if c == 1
        ylabel({'Volume of selective activation (mm^3)'}, 'FontSize', 12);
        yticks([0 500 1000 1500 2000 2500])
        yticklabels({'0' '500', '1000', '1500', '2000', '2500'})
        ax = get(gca, 'YTickLabel');
        set(gca, 'YTickLabel', ax, 'FontSize', 12)
        set(gca, 'LineWidth', 2)
    end
    ylim([0 2500])

    xticks([])
    rl =refline([0 0]);
    rl.Color = 'k';
    rl.LineWidth = 2 ;

    xlabel(contrastNames{c}, 'Interpreter', 'none', 'FontSize', 17)       
    box off
    clearvars predictionYoung predictionTeens
end

figureName = sprintf('Boxplot_NrSelectiveVoxels_5-9yo_and_13-17yo_%s', roi);
print(fullfile(figuresDir, figureName), '-dpng', '-r200')