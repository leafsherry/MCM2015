%% Compute how many people to not get the medicine for every TC
% Input
    % CV            : condition vector
    % numMedicine   : available medicine left
% Output
    % v_treat       : condition vector with not treated patient eliminated
    % v_no          : condition vector for not treated patients
                      %v_no(3) is the only none-zero number
    % numMedicine   :  medicine left after this session of treatment
    
    
function [v_treat, v_no, newNumMedicine] = computePartition(CV, numMedicine)
% num of infection
I = CV(2);
% just output when enough medicine
v_treat = CV;
v_no = zeros(size(CV,2),1);
newNumMedicine = numMedicine - I;

% when no enough medicine, randomly give
if I > numMedicine
    v_treat(2) = numMedicine;
    v_no(2) = abs(numMedicine - I);
    newNumMedicine = 0;
end
v_treat = v_treat';
end