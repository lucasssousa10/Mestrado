function [ result ] = simMultiSVM( data, ptrn, num, conf )
%SIMMLM Summary of this function goes here
%   Detailed explanation goes here

Ntest = size(data.y, 1) - floor(size(data.y, 1)*(ptrn)); %num dados teste
for i = 1 : num
    %% Embaralhando os dados
    [treinData, testData] = embaralhaDados(data, ptrn, 2);

    %% Treinamento e Teste - (LS)SVM
    fprintf('Treinamento e Teste - (LS)SVM.\n');
    [Y, time] = multisvm(treinData.x, treinData.y, testData.x, conf);
    tempoTrein(i) = time.trein;
    tempoTeste(i) = time.test/Ntest;
        
    confMatTeste(:,:,i) = confusionmat(testData.y', Y');
    
    
    %% Metricas
    matConfPorc(:,:,i) = (confMatTeste(:,:,i)./Ntest).*100;
    [metricas(:,:,i), metricasGeral(i,:)] = metricasMatConf(confMatTeste(:,:,i));    
end

% Resultado geral
% result.matConfTesteMedia = mean(confMatTeste, 3);
% result.matConfPorcMedia = mean(matConfPorc,3);
% result.metricasMedia = mean(metricas, 3);
result.metricasGeralMedia = mean(metricasGeral);

result.matConfTeste = confMatTeste;
result.matConfPorc = matConfPorc;
result.metricas = metricas;
result.metricasGeral = metricasGeral;

% Procura a matriz de confus�o mais pr�xima da acc m�dia
acc = metricasGeral(:,end);
mediaAcc = mean(acc);
[~, pos] = sort( abs ( mediaAcc - acc) );

result.matConfTesteMedia2 = confMatTeste(:,:,pos(1));
result.stdAcc = std(acc);

result.tempoTeste = tempoTeste;
result.tempoTrein = tempoTrein;
% result.tempoTesteMedio = mean(tempoTeste);
% result.tempoTreinMedio = mean(tempoTrein);

end
