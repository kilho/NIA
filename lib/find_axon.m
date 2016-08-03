function position = find_axon(startX, startY, startAngle, range, numState, r, medianValue ,disconnectEnergyBias)

resol = range/(numState-1);
initState = 0:2*pi/initNumState:2*pi-2*pi/initNumState;
cost = zeros(numState, numState*numState); %i, j*k
go = true;
idx = 1;

while(go)
    % find next path
    for i = 1:numState
        for j = 1:numState
            for k = 1:numState
                tempAngle1 = startAngle + 
                cost(i, (j-1)*numState+k) = 
            end
        end
    end
    [tempMax tempIdx] = max(cost,1);
    [finalMax finalIdx] = max(tempMax);

    % save result
    
    
    % update variable
    

    % find if we finish this iteration

end