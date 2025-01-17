function [model] =  train_MLM(learnPoints, conf)

%% Valida os valores de entrada
if nargin<1
    disp('Error: no arguments.');
    return
end

% Selecionando os K pontos de referencia
N = size(learnPoints.x, 1);
if(conf.k <= 1),
    K = round(conf.k*N);
elseif (conf.k > N)
    K = N;
else
    K = conf.k;
end

ind = randperm(N);
refX = learnPoints.x(ind(1:K), :);
refY = learnPoints.y(ind(1:K), :);

% Check data
[n,~]=size(refX);
[no,~]=size(refY);
if (n~=no) || (n<2)
    disp('Error: refPoints.x and refPoints.y do not have the same number of samples or too few samples.');
    return
end


trX = [];
trY = [];
if(exist('learnPoints', 'var') && ~isempty(learnPoints)),
    if(isstruct(learnPoints)),
        fields = isfield(learnPoints,{'x','y'});
        if (fields(1) == 1 && fields(2) == 1),
            if(size(learnPoints.x, 1) ~= size(learnPoints.y, 1))
                disp('Error: inconsistent dimensions in the learning points.')
                return
            else
                trX = learnPoints.x;
                trY = learnPoints.y; 
            end
        else
            disp('Error: Wrong struct! Missing learnPoints.x or learnPoints.y')
            return
        end
    else
        disp('Error: Learning points variable should be a struct.')
        return
    end   
end

if (~isfield(conf, 'bias')),
    conf.bias = 0; % Default bias.
end

if (~isfield(conf, 'distance')),
    conf.distance = ''; % Default distance (euclidian)
end

if (~isfield(conf, 'lambda')),
    conf.lambda = 0; % Default regularization factor.
end


%% Points used for the distance-based regression
if (isempty(trX) == 0),
    switch (conf.distance)
        case ('mahalanobis')
%             model.covX = nancov(trX);
%             if (rcond(model.covX) < 1e-12)
%                 model.covX = model.covX + 0.01*eye(size(model.covX));
%                 fprintf('------- model.covX -------\n');
%             end
%             Dx = pdist2(trX, refX, 'mahalanobis', model.covX);
%             
%             model.covY = nancov(trY);
%             if (rcond(model.covY) < 1e-12)
%                 model.covY = model.covY + 0.01*eye(size(model.covY));
%                 fprintf('------- model.covY -------\n');
%             end
%             Dy = pdist2(trY, refY, 'mahalanobis', model.covY);            
            
            model.covX = nancov(refX);
            if (rcond(model.covX) < 1e-12)
                model.covX = model.covX + 0.01*eye(size(model.covX));
                fprintf('------- model.covX -------\n');
            end
            Dx = pdist2(trX, refX, 'mahalanobis', model.covX);
            
            model.covY = nancov(refY);
            if (rcond(model.covY) < 1e-12)
                model.covY = model.covY + 0.01*eye(size(model.covY));
                fprintf('------- model.covY -------\n');
            end
            Dy = pdist2(trY, refY, 'mahalanobis', model.covY);

        case ('cityblock')
            Dx = pdist2(trX, refX, 'cityblock');
            Dy = pdist2(trY, refY, 'cityblock');
            
        case ('euclidean')
            Dx = pdist2(trX, refX);
            Dy = pdist2(trY, refY);
    end
end

if(conf.bias ~= 0),
    Dx = [ones(size(Dx, 1), 1) Dx(:,1:n)];
    n = n+1;
end

%% Set the model
if(conf.lambda ~= 0 )
    model.B = inv(Dx'*Dx + conf.lambda.*eye(n))*Dx'*Dy; 
else
    model.B =  Dx\Dy;
end

% if (rcond(model.B) < 1e-12)
%     model.B = inv(Dx'*Dx + 0.001.*eye(n))*Dx'*Dy;
% end
% if (isnan(model.B))
%     model.B = inv(Dx'*Dx + 0.001.*eye(n))*Dx'*Dy;
% end
model.refX = refX;
model.refY = refY;
model.bias = conf.bias;
model.distance = conf.distance;