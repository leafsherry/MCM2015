% compute the transformation cost and method with simplex method
% input
    % labArr        : numLab * 2, [index of district, numMedi] for the lab
    % costArr       : numLab * numTC, 
                        %(i,j): cost to tranform from lab_i to place j
    % targetMediArr : numTargetTC * 2, [index, numMedNeeded]
% output
    % transformAmountArr: 
                      % transformation distribution
    
function [ transformAmountArr, cost ] = computeCost( labArr, costArr, targetMediArr )
% compute dimension

numTargetTC = size(targetMediArr, 1);
numLab = size(labArr, 1);
numTC = size(costArr, 2);
% product constrain
productCons = labArr(:,2);
% demand constrain
demandCons = targetMediArr;

% objective matrix
    % x: m * 1
    % f: m * 1
    % b: (numLab + numTargetTC) * 1
n = numLab + numTargetTC;
m = numLab * numTargetTC;

f = reshape(costArr,m, 1);

b = [productCons; demandCons];
A = zeros(n, m);

for j = 1:m
    for i = 1:n
        % row for product
        if i <= numLab
            if mod(j,numLab) == mod(i, numLab)
                A(i,j) = 1;
            end
        % row for demand
        else
            if (i-numLab-1)*numLab+1 <= j
                if (i-numLab)*numLab+1 > j
                    A(i,j) = 1;
                end
            end
        end
    end
end

A2 = A(1:numLab,:);
b2 = productCons;


A1 = A(numLab+1:n,:);
b1 = demandCons;

% initialize the final output
%[A, subs, x, z] = simplex('min', f', A, b);
lb = zeros(m,1);

[x, fval]  = linprog(f,A1,b1,A2,b2,lb,[],[],'simplex');
transformAmountArr = reshape(x, numLab, numTC);
cost = fval;
end

