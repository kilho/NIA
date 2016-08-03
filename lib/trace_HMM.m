function [position, flag, pixelVal, med]= trace_HMM(startX, startY, startAngle, numState, r, numNode, range, img, medianValue, disconnectEnergyBias, numDisconnectThre, winSize, threDisconnect, initialXY)

position = zeros(numNode,2);              % x, y
finalProb = zeros(numNode,1);
flag = false(numNode,1);       % axon or not
%ignoreNum = 20;
%flag(1:ignoreNum) = true;
resol = range/(numState-1);
halfNumState = floor(numState/2)+1;
[height, width] = size(img);

% initialize
initState = zeros(numState,1);
M1 = zeros(numState,1);
for i = 1 : numState
    initState(i) = startAngle + resol*(i-halfNumState);
    M1(i) = p_y1_given_x1(startX, startY, initState(i), r, img, height, width);
end

% for each node calculate M and A matrix
M = zeros(numNode-1, numState);
A = zeros(numNode-1, numState);
po = cell(numNode-1,1);
ang = zeros(numNode-1, numState);
logProb = zeros(numNode-1, numState);

for i = 1:numNode-1                                      % for each node
    if i  == 1
        tempM = zeros(1,numState);
        tempA = zeros(1,numState);
        tempPosition = zeros(numState,2);
        tempAngle = zeros(1,numState);
        tempP = zeros(1,numState);
        for j = 1:numState                              % for each state of x2
            temp1 = zeros(numState,1);                  % save cost for each x1 state fixing x2 state
            temp2 = zeros(numState,2);                  % save x,y for each x1 state fixing x2 state
            temp3 = zeros(numState,1);                  % save angle for each x1 state fixing x2 state
            temp5 = zeros(numState,1);                  % save the probability
            for k = 1:numState                          % for each state of x1
                temp4 = initState(k) +  resol*(j-halfNumState);   % calculate x2 angle state
                [p, nx, ny] = p_y2_given_x1x2(startX, startY, initState(k), temp4, r, r, img, height, width);
                temp1(k) = M1(k) + p;
                temp2(k,:) = [nx,ny];
                temp3(k) = temp4;
                temp5(k) = p;
            end
            [tempM(j), tempA(j)] = max(temp1);
            tempPosition(j,:) = temp2(tempA(j),:);
            tempAngle(j) = temp3(tempA(j));
            tempP(j) = temp5(tempA(j));
        end
        M(i,:) = tempM;
        A(i,:) = tempA;
        po{i} = tempPosition;
        ang(i,:) = tempAngle;
        logProb(i,:) = tempP;
        
    else  
        tempM = zeros(1,numState);
        tempA = zeros(1,numState);
        tempPosition = zeros(numState,2);
        tempAngle = zeros(1,numState);
        tempP = zeros(1,numState);
        for j = 1:numState                              % for each state of x2
            temp1 = zeros(numState,1);                  % save cost for each x1 state fixing x2 state
            temp2 = zeros(numState,2);                  % save x,y for each x1 state fixing x2 state
            temp3 = zeros(numState,1);                  % save angle for each x1 state fixing x2 state
            temp5 = zeros(numState,1);                  % save the probability
            for k = 1:numState                          % for each state of x1
                temp4 = ang(i-1,k) +  resol*(j-halfNumState);     % calculate x2 angle state
                [p, nx, ny] = p_yi2_given_xi1xi2(po{i-1}(k,1), po{i-1}(k,2), temp4, r, img, height, width);
                temp1(k) = M(i-1,k) + p;
                temp2(k,:) = [nx,ny];
                temp3(k) = temp4;
                temp5(k) = p;
            end
            [tempM(j), tempA(j)] = max(temp1);
            tempPosition(j,:) = temp2(tempA(j),:);
            tempAngle(j) = temp3(tempA(j));
            tempP(j) = temp5(tempA(j));
        end
        M(i,:) = tempM;                                 % not essential to save every M
        A(i,:) = tempA;
        po{i} = tempPosition;
        ang(i,:) = tempAngle;  
        logProb(i,:) = tempP;
    end
end

% find node which maximize the cost function
for i = numNode:-1:1
    if i == numNode
        [logP, maxIdx] = max(M(i-1,:));
        position(i,:) = [po{i-1}(maxIdx,1) po{i-1}(maxIdx,2)];
        finalProb(i) = logProb(i-1, maxIdx);
    elseif i == 1
        maxIdx = A(i,maxIdx);
        position(i,:) = [round(r*cos(initState(maxIdx))+startX) round(r*sin(initState(maxIdx))+startY)];
        finalProb(i) = M1(maxIdx);
    else
        maxIdx = A(i,maxIdx);
        position(i,:) = [po{i-1}(maxIdx,1) po{i-1}(maxIdx,2)];
        finalProb(i) = logProb(i-1,maxIdx);
    end
end

% find end of position

% threshold = log(medianValue + disconnectEnergyBias);
% tempBinary = double(finalProb>threshold);
% figure(100)
% subplot(2,1,1)
% stem(finalProb)
% subplot(2,1,2)
% stem(tempBinary)
% 
% for i = 1:numNode-numDisconnectThre+1
%     if sum(tempBinary(i:i+numDisconnectThre-1)) ~= 0
%         flag(i) = true;
%     else
%         break
%     end
% end
% flag = [true; flag];
position = [startX startY; position];
% get rid of points which is boundary, overlap and near the soma
validFlag = false(size(position,1),1);
validFlag(1) = true;
for i = 2:size(position,1)
    if position(i,1) <= 5 || position(i,1) >= width-5 || position(i,2) <= 5 || position(i,2) >= height-5
        break
    end
    if sqrt(sum((initialXY-position(i,:)).^2)) < 70
        break
    end
    if min(sqrt((position(1:i-1,1)-position(i,1)).^2 + (position(1:i-1,2)-position(i,2)).^2)) < r-2
        break
    end
    validFlag(i) = true;
end
position = position(validFlag,:);
    
newNumNode = size(position,1);
intensitySeries = zeros(newNumNode-1, r);
flagIntensitySeries = double(zeros(newNumNode-1,r));
medianValueSeries = zeros(newNumNode-1,1);
for i = 1:newNumNode-1
    point1 = position(i,:);
    point2 = position(i+1,:);
    [intensitySeries(i,:), medianValueSeries(i)] = get_intensity_median(point1, point2, r, winSize, img, height, width);
    flagIntensitySeries(i,:) = double(intensitySeries(i,:) > medianValueSeries(i));
end
for i = 1:newNumNode-numDisconnectThre
    temp1 = flagIntensitySeries(i:i+numDisconnectThre-1,:)';
    temp = temp1(:);
    if sum(temp) > r*threDisconnect*numDisconnectThre;
        flag(i) = true;
    else
        break
    end
end
pixelVal = intensitySeries';
pixelVal = pixelVal(:);
med = medianValueSeries;
flag = [true; flag];