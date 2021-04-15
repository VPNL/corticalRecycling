% This script runs linear mixed models on the mean selectivity for pairwise contrasts in emerging and waning ROIs.
% For each ROI, two kinds of plots are created one for each pairwise
% contrast.
% Fo instance, in case of the emerging word ROI one plot shows the data for
% the words vs faces contrast, and one for the words vs limbs contrast.

%% Set up paths and files
dataDir = './data/';
figuresDir = './figures/';
fileName = 'selectiveVoxelsPairwiseContrast_all29Subjects_noIDs.mat';


load([dataDir fileName])

ROIs = {'lh_pOTS_word_initialEndDiffDomainDep',...
    'lh_OTS_limb_initialEndDiffDomainDep', ...
    'rh_OTS_limb_initialEndDiffDomainDep',...
    'lh_pFus_faceadultfacechild_initialEndDiffDomainDep'...
    'rh_pFus_faceadultfacechild_initialEndDiffDomainDep'};       
            
%% Loop through ROIs and contrasts
modelParams = struct;

for r= 1:length(ROIs)
    roi = ROIs{r};
    
    if contains(roi, 'word')
        activeCategoryName = 'Words';
        
        % contrast words vs limbs
        controlCategory_1Name='Limbs'; 
        % and words vs faces
        controlCategory_2Name='AdultFacesChildFaces';
        
       
    elseif contains(roi, 'face')
        activeCategoryName ='AdultFacesChildFaces';
        
        % contrast faces vs words
        controlCategory_1Name='Words'; 
       % and faces versus limbs
        controlCategory_2Name='Limbs'; 
        
    elseif contains(roi, 'limb')
        activeCategoryName ='Limbs';
        
        % contrast limbs vs words
        controlCategory_1Name='Words';       
        % and limbs vs faces
        controlCategory_2Name='AdultFacesChildFaces';
        
    end
     
     contrasts={[activeCategoryName 'VS' controlCategory_1Name], [activeCategoryName 'VS' controlCategory_2Name]};
     
    for c=1:length(contrasts)
        contrast= contrasts{c};
        controlCategory=extractAfter(contrast, 'VS');
        % structure data into table format to prepare for LMM
        tbl = structureVoxelData4Table(dataSelectVoxels, roi, 'mean', contrast);
        
        % run LMM
        modelParams = runLMM(tbl, 'voxelData', 'age', 'subj', roi, contrast, modelParams);
        
        %% Create a scatter plot for this contrast and ROI
        figure(1)
        
        % Create CI for slope matching those produced in R
        tblnew = table();
        age_r = [60 220];
        tblnew.age=linspace(age_r(1),age_r(2))';
        tblnew.subj = repmat({'a'},100,1);
        [ypred, yCI, DF] = predict(modelParams.(roi).(contrast).lme, tblnew);    
        
        yfit_meanline = polyval([modelParams.(roi).(contrast).slope modelParams.(roi).(contrast).intcpt], age_r);  
        eb = errorbar3(tblnew.age', ypred', [yCI(:,1)'; yCI(:,2)'] , 1, [0.8 0.8 0.8]);
        hold on
        
        
        if contains(char(controlCategory), 'Limbs')
            colorRGB= [1 0.844 0];
        elseif contains(char(controlCategory), 'Faces')
             colorRGB= [236/255 112/255 99/255];        
        elseif contains(char(controlCategory), 'Words')
            colorRGB= [133/255 193/255 233/255 ];
        end
        
        %% Add individual data to plot 
        allsubj = unique(tbl.subj, 'stable');
        for as=1:length(allsubj)
            ageVals = [];
            voxelVals =  [];
            currentSubj = allsubj{as};
            
            colIndexVoxelData = find(strcmp(tbl.Properties.VariableNames, 'voxelData'), 1);
            voxelVals = tbl{strcmp(tbl.subj,currentSubj), colIndexVoxelData};

            colIndexAgeData = find(strcmp(tbl.Properties.VariableNames, 'age'), 1);
            ageVals = tbl{strcmp(tbl.subj,currentSubj), colIndexAgeData};

            plot([ageVals(1) ageVals(end)], [voxelVals(1) voxelVals(end)],  '-', 'Color', colorRGB, 'LineWidth', 2)

            clearvars ageVals voxelVals currentSubj
        end
        
        %% Add overall regression line, and zero line
        r= refline(modelParams.(roi).(contrast).slope, modelParams.(roi).(contrast).intcpt);
        r.Color = [0.5 0.5 0.5];
        r.LineWidth = 4;

        % Add  zero line
        z = refline([0 0]);
        z.Color = [0 0 0];
        
        %% Format axes, title
        set(gca, 'YTick', [-4 -2 0 2 4 6 8])
        set(gca,'YTicklabel', [-4 -2 0 2 4 6 8],'FontSize',18 )
        ylim([-4.5 8.5])
    
        yStr= [activeCategoryName ' vs ' controlCategory ' (t)'];
        if contains(yStr, 'Child')
            yStr=strrep(yStr, 'AdultFacesChildFaces', 'Faces');
        end
        ylabel(yStr);
        
        xlim([4.2*12 18*12])
        xlabel({'age (years)'})
        set(gca,'XTick', [12*5 12*9 12*13 12*17]) 
        set(gca,'XTicklabel', [5 9 13 17],'FontSize',18 )
        
        % add title
        set(gca,'TickLength', [0 0.0]);
        currentROINoUnderscore = strrep(roi, '_', ' ');
        roiStr= extractBefore( currentROINoUnderscore, 'initial');
        if contains(roiStr, 'limb')
            titlestr = sprintf('Waning %s', roiStr);
        else
            titlestr = sprintf('Emerging %s', roiStr);
        end
        title(titlestr, 'Interpreter', 'none', 'FontSize',17)

        %remove box outline
        box off
        
        %% save figure
        figureName = sprintf('LinePlot_PairwiseContrast_%s_%s', roiStr, contrast);
        print(fullfile(figuresDir, figureName), '-dpng', '-r200')
        
        clearvars tbl sessNames voxelData age subj
        clf
        
       % end of contrast loop 
    end
   % end of roi loop 
end

