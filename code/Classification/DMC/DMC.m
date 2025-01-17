function [results] = DMC(dataset, ptrn, numRepet)


[N, ~] = size(dataset.x);
limit = floor(ptrn*N);

for i = 1 : numRepet,
    %% Embaralhando os dados
    ind = randperm(N);
    
    trainData.x = dataset.x(ind(1:limit), :);
    trainData.y = dataset.y(ind(1:limit), :);
   
    testData.x = dataset.x(ind(limit+1:end), :);
    testData.y = dataset.y(ind(limit+1:end), :);
    
    
    %% Treinando o DMC
    [centroides] = trainDMC(trainData);
    
    
    %% Testando o DMC
    [Yh] = testeDMC(centroides, testData);
%     [Yh] = teste2DMC(centroides, testData, N);
    
    
    %% Matriz de confusao e acur�cia
    [~, index] = max(Yh');
    [~, target] = max(testData.y');
    
    confusionMatrices{i} = confusionmat(target, index);
    accuracy(i) = trace(confusionMatrices{i}) / length(testData.y);
    
end

meanAccuracy = mean(accuracy);

%% Procurando a matriz de confus�o mais pr�xima da acur�cia m�dia
[~, posicoes] = sort( abs ( meanAccuracy - accuracy ) );


%%
results.accuracy = meanAccuracy;
results.std = std(accuracy);
results.confusionMatrix = confusionMatrices{posicoes(1)};
results.confusionMatrices = confusionMatrices;


end