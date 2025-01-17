close all; clear all; clc; addpath('..');

%% Pr�-processamento
dados = carregaDados('iris2D.data', 4);

%% Configura��es gerais
ptrn = 0.8;
<<<<<<< HEAD
numRodadas = 10;
numFolds = 5;
metodo = 'LS';
=======
numRodadas = 2;
numFolds = 5;
metodo = 'QP';
>>>>>>> origin/master
fkernel = 'rbf';
options.MaxIter = 9000000;


%% Criando as combina��es de par�metros para a valida��o cruzada

% paraC = ceil(0.1 * ptrn * size(dados.y, 1)) - 20 : 2 :ceil(0.1 * ptrn * size(dados.y, 1)) + 50;
<<<<<<< HEAD
paraC = 2.^(-5:2:9);
% paraC = 0.001:0.01:0.1;
=======
paraC = 2.^(-5:13);
>>>>>>> origin/master

i = 1;
if (strcmp('rbf', fkernel) == 1)
    for sigma = 2.^(-15:5)
        
        for c = paraC
            params{1,i} = c;
            params{2,i} = fkernel;
            params{3,i} = sigma;
            params{4,i} = metodo;
            i = i + 1;
        end
    end
else
    
    for c = paraC
        params{1,i} = c;
        params{2,i} = fkernel;
        params{3,i} = metodo;
        i = i + 1;
    end
end

%% Avaliando o m�todo
for i = 1 : numRodadas,
    %% Embaralhando os dados
    [dadosTrein, dadosTeste] = embaralhaDados(dados, ptrn, 2);
    
    
    %% Valida��o cruzada
    fprintf('Cross validation and grid search...\n')
    [optParams{i}, Ecv{i}] = otimizadorSVM(dadosTrein, params, numFolds);
    
    
    %% Treinamento do SVM
    fprintf('Treinando o SVM...\nRodada %d\n', i)
    
    paraC = optParams{i}{1,1};
    fkernel = optParams{i}{2,1};
    if (strcmp('rbf', fkernel) == 1)
        sigma = optParams{i}{3,1};
        tic
        modelo{i} = svmtrain(dadosTrein.x, dadosTrein.y,'kernel_function',...
            fkernel,'rbf_sigma',sigma,'boxconstraint',paraC,...
            'method',metodo,'kernelcachelimit',15000,'Options', options);
        tempoTreino(i) = toc;
    else
        tic
        modelo{i} = svmtrain(dadosTrein.x, dadosTrein.y,'kernel_function',...
            fkernel,'boxconstraint',paraC,'method',metodo,...
            'kernelcachelimit',15000,'Options', options);
        tempoTreino(i) = toc;
    end
    numSV(i) = size(modelo{i}.SupportVectors,1);
        
    %% Testando o SVM
    fprintf('Testando o SVM...\nRodada %d\n\n', i)
    tic
    Yh = svmclassify(modelo{i}, dadosTeste.x);
    tempoTeste(i) = toc/size(Yh,1);
    
    % Matriz de confusao e acur�cia    
    matrizesConf{i} = confusionmat(dadosTeste.y, Yh);
    acuracia(i) = trace(matrizesConf{i}) / size(Yh,1);
end

mediaAcc = mean(acuracia);

% Procurando a matriz de confus�o mais pr�xima da acur�cia m�dia
[~, posicoes] = sort( abs ( mediaAcc - acuracia ) );


desvPadr = std(acuracia);
matrizConfMedia = matrizesConf{posicoes(1)};
clear Yh dados dadosTeste dadosTrein i c posicoes
