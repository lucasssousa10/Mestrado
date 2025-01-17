function [ resultado ] = buscaTopologiaRBF( dados, params, conf )
%BUSCATOPOLOGIASOM Summary of this function goes here
%   Detailed explanation goes here

save(conf.fileName);
acc = zeros(conf.treinos, length(params));
for i = 1 : conf.treinos,
    %% Embaralhando os dados
    [learnPoints{i}, testData{i}] = embaralhaDados(dados, conf.ptrn, 2);
    
    for j = 1: length(params),
        tic
        fprintf('Busca Topologia RBF. %d - %d.\n', i, j);
        [modelo{i,j}] = treinoRBF(learnPoints{i}, params{j});
        tempoTrein(i,j) = toc;
        
        [Yh] = testeRBF(modelo{i,j}, testData{i});        
        
        [~, target] = max(testData{i}.y');
        confusionMatrices{i, j} = confusionmat(target, Yh);
        acc(i,j) = trace(confusionMatrices{i, j}) / length(target);
                
        fprintf('ACC: %f\n',  acc(i, j));
        
        save(conf.fileName,'-append');
        
    end
end

if conf.treinos == 1
    resultado.varianciaTeste = zeros(1, size(acc,2));
else
    resultado.varianciaTeste = var(acc, 1);
end
resultado.mediaTeste = mean(acc, 1);
resultado.tempoTreino = tempoTrein;

save(conf.fileName,'-append');

end

