% plotBetas_Boxplot

% DESCRIPTION: This script creates boxplots for beta values for each of the 10 
% categories  in emerging and waning ROIs for young children (5-9yo) and teens
% (13-17yo). The model prediction for the mean age of participants in each
% age group is plotted on top of the boxplots.

fileName = 'betas_noSubjIDS.mat';
dataDir = './data/';
figuresDir = './figures/';

load([dataDir fileName])

% Betas for categories are saved in the order of occurence in the par files
categoryNames = {'AdultFaces', 'ChildFaces', 'NoHeadBody', 'Limbs',...
        'Cars', 'Guitars', 'Corridors', 'Houses', 'Words', 'Number'}; 
    
%% First run LMM so the model prediction can be plotted on the boxplots

rois = fieldnames(responseData);
modelParams = struct;

for r= 1:length(rois)
    roi = rois{r};
    for c=1:length(categoryNames)
       % prepare data for LMM
        tbl = structureVoxelData4Table(responseData, roi, 'betas', c);
        modelParams = runLMM(tbl, 'voxelData', 'age', 'subj', roi, categoryNames{c}, modelParams);
    end
    
end

%% Select data for the two age groups and create a figure for each ROI

% Plot categories in this order:
newOrder = [10 9 4 3 1 2 5 6 8 7];
newLabels = {'N', 'W', 'L', 'B', 'AF', 'CF', 'C', 'G', 'H', 'Cor'};


%% Set colors
mycolorsYoung = [121/255 134/255 203/255;... %num
    133/255 193/255 233/255; ...% word
    255/255 235/255 59/255;... % limb
    240/255 178/255 122/255 ; ...%bodies
    236/255 112/255 99/255;... % adult faces
    146/255 43/255 33/255; ...% kid faces
    153/255 0/255 255/255;...
    255/255 152/255 255/255;...
    156/255 204/255 101/255;...
    0/255 105/255 92/255];

mycolorsOld = [57/255 73/255 171/255;... % num
    52/255 152/255 219/255 ;... % word
    251/255 192/255 45/255;... % limb
    230/255 126/255 34/255 ;...  %bodies
    203/255 67/255 53/255;... % adult faces
    100/255 30/255 22/255;... % kid faces
    0.4940 0.1840 0.5560;...
    0.75 0 0.75;...
    104/255 159/255 56/255;...
    0/255 77/255 64/255];

%% Loop through ROIS

for r= 1:length(rois)
    roi = rois{r};
    
    figure(1)
    set(gcf, 'Position', [0 0 1100 600])
    
    for ca= 1:length(categoryNames)
        subplot(1, length(categoryNames),ca)
        
        % select which data to plot
        [youngKidsSelected, youngKidsAgesSelected, youngKidsSessionsSelected,...
            teensSelected, teensAgesSelected, teensSessionsSelected]= selectData2AgeGroups(responseData, roi);
        youngKidsData= [];
        teenData= [];
        
        for y=1:length(youngKidsSelected)
           youngKidsData(y,1) =  responseData.(roi).(youngKidsSelected{y}).(youngKidsSessionsSelected{y}).betas(newOrder(ca));
        end
    
        for t=1:length(teensSelected)
           teenData(t,1) = responseData.(roi).(teensSelected{t}).(teensSessionsSelected{t}).betas(newOrder(ca));
        end
        
        bp = boxplot([youngKidsData; teenData],...
            [repmat({'5-9'}, length(youngKidsData),1); repmat({'13-17'}, length(teenData),1)], 'widths', 1);
        hold on
        set(gca, 'LineWidth', 3)
        set(gca, 'XColor', [0.3 0.3 0.3])
        xlabel(newLabels(ca))
        
        % Format boxplot Lines
        gcf = formatBoxPlotLines(gcf, bp);
        
        % Format color
        b = findobj(gca,'Tag','Box');
        patch(get(b(2),'XData'),get(b(2),'YData'), mycolorsYoung(ca, :), 'FaceAlpha',.8 );
        patch(get(b(1),'XData'),get(b(1),'YData'), mycolorsOld(ca, :), 'FaceAlpha',.8 );
        
        
        %% Add model prediction to boxplot
        youngKidsAgesSelectednoNans = youngKidsAgesSelected(~isnan(youngKidsData));
        teensAgesSelectednoNans = teensAgesSelected(~isnan(teenData));
        
        meanKidsAgeYears = nanmean(floor(youngKidsAgesSelectednoNans./12));
        meanTeensAgeYears = nanmean(floor(teensAgesSelectednoNans./12));
        predictionYoung = modelParams.(roi).(categoryNames{newOrder(ca)}).intcpt + modelParams.(roi).(categoryNames{newOrder(ca)}).slope*meanKidsAgeYears*12;
        predictionTeens = modelParams.(roi).(categoryNames{newOrder(ca)}).intcpt + modelParams.(roi).(categoryNames{newOrder(ca)}).slope*meanTeensAgeYears*12;
        
        plot(1, predictionYoung, 'd', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 11 )
        plot(2, predictionTeens, 'd', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 11 )
        
        %% Format axes
        if ca ~= 1
            set(gca, 'YColor', [1 1 1])
        end

        if ca==1
            ylabel('Beta Value', 'FontSize', 12);
            yticks([-2 -1 0  1 2])
            yticklabels({'-2', '-1', '0', '1', '2'})
            ax = get(gca, 'YTickLabel');
            set(gca, 'YTickLabel', ax, 'FontSize', 12)
            set(gca, 'LineWidth', 3)
            set(gca,'TickLength',[0.006, 0.01])
        end
        ylim([-1.3 2.8])
        box off
        
        rl=refline([0 0]);
        rl.Color = 'k';
        rl.LineWidth = 2;
        xticks([])
        
        % Add a title 
        if contains(roi, 'limb')
            titleStr = sprintf('Waning %s', extractBefore(roi, '_initial') );
        else
            titleStr = sprintf('Emerging %s', extractBefore(roi, '_initial') );
        end
        if ca==5
           title(titleStr, 'Interpreter', 'none') 
        end
        clearvars predictionYoung predictionTeens youngKidsAgesSelected teensAgesSelected
    end
    
    % Save figure
    figureName = sprintf('Boxplot_betas_%s', roi);
    print(fullfile(figuresDir,figureName), '-dpng', '-r200')
    
end