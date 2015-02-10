% For computing the current target district
    % input : 
        % curMedicine   : current medicine produced by three centers
        
        % dayCompute    : initial conditions in every treatment center
                            % Dimension : numTC (Num. treatment center) * 
                                          % * CV (condition vector)
                            % CV        : [  
                                %H: no infection + live
                                %I: infection + no medicine
                                %C: infection + advanced
                                %D: no infection + dead
                            %]
        % index         : Used for determine which one to give dirst
        % labArr        : the index of district and numMedi for the lab
                                %[index, numMedProducted]
                            
    % output :
        % v_treatArr    : numTC * CV, if not treated this time, I = 0
        % v_noArr       : condition vector for not treated patients
                                %v_no(3) is the only none-zero number
        % curMedicine   : medicine left after this session of treatment
        % targetMediArr : demand arr, numTC * 1, non-zero if needed
        
function [v_treatArr, v_noArr, targetMediArr, curMedicine] = ...
                            computeTargetDistrict...
                                (curMedicine, index, dayCompute, labArr)
    
    
                            % compute dimension
    numTC = size(dayCompute, 1);
    CV = size(dayCompute, 2);
    numLab = size(labArr, 1);
    % initialize two arr
    v_treatArr = zeros(numTC, CV);
    v_noArr = zeros(numTC, CV);
    
    % extract the I arr from dayCompute numTC * 1
    IArr = dayCompute(:,2);
    
    % Initialize reserved medicine array
    reserveLab = zeros(numLab, 2);
    % distribute to local first
    for i = 1: numLab
        curLabMed = labArr(i,2);
        curLabIndex = labArr(i,1);
        reserveLab(i,1) = curLabIndex;
        curI = IArr(curLabIndex,1);
        if(curI < curLabMed)
            reserveLab(i,2) = curI;
            curMedicine = curMedicine - curI;
        else
            reserveLab(i,2) = curLabMed;
            curMedicine = curMedicine - curLabMed;
        end
    end
    
    % extract sub index that could use up the curMedicine
    total = 0;
    curIndex = 0;
    while (total < curMedicine)
        curIndex = curIndex + 1;
        curI = IArr(index(curIndex), 1);
        total = total + curI;
        if curIndex >= numTC
            break;
        end
    end
    
    % compute v_treatArr, v_noArr
    for k = 1: numTC
        % proritize
        i = index(k);
        curTC = dayCompute(i,:);
        % if it's a lab session
        if find(reserveLab(:,1) == i)
            curLab = reserveLab(find(reserveLab(:,1) == i),:);
            curMed = curLab(:,2);
            curTC(:,2) = curTC(:,2) - curMed;
            [v_treat, v_no, curMedicine] = computePartition(curTC, curMedicine);
            v_treat(2) = v_treat(2) + curMed;
            v_treatArr(i,:) = v_treat';
            v_noArr(i,:) = v_no';
        else
            [v_treat, v_no, curMedicine] = computePartition(curTC, curMedicine);
            v_treatArr(i,:) = v_treat';
            v_noArr(i,:) = v_no';
        end
        
    end
    % target medicine Arr
    targetMediArr = v_treatArr(:,2);
    
end

