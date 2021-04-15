% This script runs a linear mixed model and saves the model parameters in
% a struct
function modelParams = runLMM(tbl, dependentVar, predictorVar, groupingVar, roi, contrast, modelParams)

% Set up and run random intercept model
randomIntModelString = sprintf('%s ~ %s + (1 | %s) ', dependentVar, predictorVar, groupingVar);
randomIntModel = fitlme(tbl, randomIntModelString)

% save modelParams.
modelParams.(roi).(contrast).slope = randomIntModel.Coefficients{2,2};
modelParams.(roi).(contrast).slope_lower = randomIntModel.Coefficients{2,7};
modelParams.(roi).(contrast).slope_upper = randomIntModel.Coefficients{2,8};
modelParams.(roi).(contrast).intcpt = randomIntModel.Coefficients{1,2};
modelParams.(roi).(contrast).lme = randomIntModel;
end


