function modelParams =runLMMMultPredictors(tbl, dependentVar, predictorVar1, predictorVar2, groupingVar, roi, modelParams)

% Set up and run random intercept model with 1 Predictor
randomInt1PredModelString = sprintf('%s ~ %s + (1 | %s) ', dependentVar, predictorVar1, groupingVar);
randomIntModel1Pred = fitlme(tbl, randomInt1PredModelString)

% Set up and run random intercept model with 2 Predictors
randomInt2PredModelString = sprintf('%s ~ %s + %s + (1 | %s) ', dependentVar, predictorVar1, predictorVar2, groupingVar);
randomIntModel2Pred = fitlme(tbl, randomInt2PredModelString)

LRTest = compare(randomIntModel1Pred, randomIntModel2Pred)

% IF both predictor contribute to model fit, save them
if LRTest{2,8} < 0.05
    modelParams.(roi).intcpt = randomIntModel2Pred.Coefficients{1,2};
    modelParams.(roi).modelPred1 = randomIntModel2Pred.Coefficients{2,1};
    modelParams.(roi).(randomIntModel2Pred.Coefficients{2,1}) = randomIntModel2Pred.Coefficients{2,2};
    modelParams.(roi).modelPred2 = randomIntModel2Pred.Coefficients{3,1};
    modelParams.(roi).(randomIntModel2Pred.Coefficients{3,1}) = randomIntModel2Pred.Coefficients{3,2};
end



end