%% Comput which center to transform the medicines to -> min trans fee
    % input: 
        % reachTCMat (numTC * numTC)
            % reachable from i to j: reachTCMat(i,j) = 1, 0 otherwise
        % targetTC (numTargetTC * 1)
            % targeted TC.
    % output:
        % transitTC (transitTC * 1)
     
function transitTC = computeTransMethod(reachTCMat, targetTC)

reachTargetTCMat = reachTCMat(:,targetTC);
[sortReach, index] = sort(-1*sum(reachTargetTCMat,2));
sortReach = sortReach * -1;
if(sortReach(1) == 3)
    transitTC = [index(1)];
elseif(sortReach(1) == 1)
    transitTC = targetTC;
else
    reach = reachTargetTCMat(index(1),:);
    stillTarget = targetTC(find(reach==0));
    transitTC = [index(1) stillTarget];
end

end