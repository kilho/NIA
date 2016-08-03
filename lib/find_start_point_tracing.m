function [startX, startY, startAngle] = find_start_point_tracing(initialX, initialY, initNumState, initState, initR, likelihood, threRatioInit, NMSsize, height, width)

% find starting points for tracing by threholding + NMS
M               = zeros(initNumState,1);  
tempX           = zeros(initNumState,1);
tempY           = zeros(initNumState,1);


for k = 1 : initNumState
    [M(k), tempX(k), tempY(k)] = get_intensity(initialX, initialY, initState(k), initR, likelihood, height, width);
end

tempMax = max(M);
ratioIntensity = M/tempMax;
tempBinary = (ratioIntensity>threRatioInit);

% NMS
for k = 1 : initNumState
    if tempBinary(k) == true
        if k > NMSsize && k <= initNumState - NMSsize
            temp1 = ratioIntensity(k-NMSsize:k+NMSsize);
        elseif k <= NMSsize
            temp1 = [ratioIntensity(initNumState-(NMSsize-k):initNumState); ratioIntensity(1:k+NMSsize)];
        elseif k >initNumState-NMSsize
            temp1 = [ratioIntensity(k-NMSsize:initNumState); ratioIntensity(1:k-initNumState+NMSsize)];
        end
        temp2 = max(temp1);
        if temp2 ~= ratioIntensity(k);
            tempBinary(k) =false;
        else
            if k > NMSsize && k <= initNumState - NMSsize
                tempBinary(k-NMSsize:k+NMSsize) = false;
            elseif k <= NMSsize
                tempBinary(initNumState-(NMSsize-k):initNumState) = false;
                tempBinary(1:k+NMSsize) = false;
            elseif k >initNumState-NMSsize
                tempBinary(k-NMSsize:initNumState) = false;
                tempBinary(1:k-initNumState+NMSsize) = false;
            end
            tempBinary(k) = true;
        end
    end
end
startX = tempX(tempBinary);
startY = tempY(tempBinary);
startAngle = initState(tempBinary);


