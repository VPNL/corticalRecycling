function tbl = structureVoxelData4Table(data, roi, metric, contrast)        
% Inputs: 

% (1) data, this is the struct in which the data is saved by subjects and
% sessions
% (2) the ROI, for example 'lh_vtc_lateral'
% (3) metric: if the number of above-threshold voxels is of interest choose
% 'nr', if the mean-selectivity is of interest, choose 'mean'

subjects = fieldnames(data.(roi));
sessions = [];
voxelData= [];
age = [];
subj ={};
sessNames ={};

for s=1:length(subjects)
    subject=subjects{s};
    sessions = fieldnames(data.(roi).(subject));

    for ses=1:length(sessions)
        if strcmp(metric, 'betas')
            voxelData(end+1,1)= data.(roi).(subject).(sessions{ses}).betas(contrast);
        else
            voxelData(end+1,1)= data.(roi).(subject).(sessions{ses}).([metric contrast]);
        end
        age(end+1,1)= data.(roi).(subject).(sessions{ses}).age;
        subj{end+1,1} =subject;
        sessNames{end+1,1} = sessions{ses};
    end

end

% Combine the data into a table to run a LMM
tbl= table(voxelData, age, subj, sessNames);