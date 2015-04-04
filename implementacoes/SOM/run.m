close all; clear all; clc;
addpath('..');

%% Carregando os dados
data = load('../iris.data');
dataset.x = data(:, 1:4);
dataset.y = data(:, 5:7);
clear data;

%% Normalizando os dados
dataset.x = normalizaDados(dataset.x, 1);

%% Configurações gerais
ptrn = 0.75;
numRepet = 2;

% Topologia da rede
config.vizinhos = 1;
config.topologia = 'g'; %g grid; h hexagonal
config.dist = 'b'; % b boxdist; l linkdist
config.tamanho = [8 8];
config.epocas = 300;

result = som(dataset, ptrn, numRepet, config)


%% Plotando o boxplot
rotulos = [];
for i = 1:numRepet
    rotulos = [rotulos; 'SOM Teste'];
end
for i = 1:numRepet
    rotulos = [rotulos; 'SOM Train'];
end
valores = [result.erroTeste result.erroTrain];
boxplot(valores', rotulos);

ylabel('Erro de quantização', 'FontSize', 12)