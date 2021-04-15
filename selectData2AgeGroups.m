function [youngKidsSelected, youngKidsAgesSelected, youngKidsSessionsSelected,...
    teensSelected, teensAgesSelected, teensSessionsSelected]= selectData2AgeGroups(data, roi)

youngKidsInAgeRange= {};
youngKidsSessionsInAgeRange= {};
youngKidsInRangeAges = [];
teensInAgeRange= {};
teensSessionsInAgeRange= {};
teensInRangeAges = [];

%% Select subjects belonging to one of the two age groups
subjects = fieldnames(data.(roi));
for s=1:length(subjects)
    sessions= {};
    currentSubject=subjects{s};
    sessions =  fieldnames(data.(roi).(currentSubject));
    
    for ses=1:length(sessions)
        currentSession = sessions{ses};
        if data.(roi).(currentSubject).(currentSession).age < 120
            youngKidsInAgeRange{1,end+1} = currentSubject ;
            youngKidsSessionsInAgeRange{1,end+1}= currentSession;
            youngKidsInRangeAges(end+1) =data.(roi).(currentSubject).(currentSession).age;
        elseif data.(roi).(currentSubject).(currentSession).age >= 156
            teensInAgeRange{1,end+1} = currentSubject;
            teensSessionsInAgeRange{1,end+1} = currentSession;
            teensInRangeAges(end+1) =data.(roi).(currentSubject).(currentSession).age;
        end
        
    end
end

%% Select only one session per subject in each group
[C,indexY,IC] = unique(youngKidsInAgeRange,'stable');
youngKidsSelected = youngKidsInAgeRange(indexY);
youngKidsAgesSelected = youngKidsInRangeAges(indexY);
youngKidsSessionsSelected = youngKidsSessionsInAgeRange(indexY);

% For teens the last session in each subject is selected
[CT,indexT,ICT] = unique(teensInAgeRange, 'last');
teensSelected = teensInAgeRange(indexT);
teensAgesSelected = teensInRangeAges(indexT);
teensSessionsSelected = teensSessionsInAgeRange(indexT);
