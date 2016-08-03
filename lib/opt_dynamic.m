function [logP position] = opt_dynamic(initialX, initialY, initNumState, initR, numState, r, numNode, range, img, medianValue)

position = zeros(numNode,2);  % x, y, non
resol = range/(numState-1);
halfNumState = floor(numState/2)+1;

% initialize
initState = 0:2*pi/initNumState:2*pi-2*pi/initNumState;
M1 = zeros(initNumState,1);
for i = 1 : initNumState
    M1(i) = p_y1_given_x1(initialX, initialY, initState(i), initR, img);
end

% for each node calculate M and A matrix
M = zeros(numNode-1, numState);
A = zeros(numNode-1, numState);
po = cell(numNode-1,1);
ang = zeros(numNode-1, numState);

for i = 1:numNode-1                                      % for each node
    if i  == 1
        tempM = zeros(1,numState);
        tempA = zeros(1,numState);
        tempPosition = zeros(numState,2);
        tempAngle = zeros(1,numState);
        for j = 1:numState                              % for each state of x2
            temp1 = zeros(initNumState,1);              % save cost for each x1 state fixing x2 state
            temp2 = zeros(initNumState,2);              % save x,y for each x1 state fixing x2 state
            temp3 = zeros(initNumState,1);              % save angle for each x1 state fixing x2 state
            for k = 1:initNumState                      % for each state of x1
                temp4 = initState(k) +  resol*(j-halfNumState);   % calculate x2 angle state
                [p nx ny] = p_y2_given_x1x2(initialX, initialY, initState(k), temp4, initR, r, img);
                temp1(k) = M1(k) + p;
                temp2(k,:) = [nx,ny];
                temp3(k) = temp4;
            end
            [tempM(j) tempA(j)] = max(temp1);
            tempPosition(j,:) = temp2(tempA(j),:);
            tempAngle(j) = temp3(tempA(j));
        end
        M(i,:) = tempM;
        A(i,:) = tempA;
        po{i} = tempPosition;
        ang(i,:) = tempAngle;
    else  
        tempM = zeros(1,numState);
        tempA = zeros(1,numState);
        tempPosition = zeros(numState,2);
        tempAngle = zeros(1,numState);
        for j = 1:numState                              % for each state of x2
            temp1 = zeros(numState,1);                  % save cost for each x1 state fixing x2 state
            temp2 = zeros(numState,2);                  % save x,y for each x1 state fixing x2 state
            temp3 = zeros(numState,1);                  % save angle for each x1 state fixing x2 state
            for k = 1:numState                          % for each state of x1
                temp4 = ang(i-1,k) +  resol*(j-halfNumState);     % calculate x2 angle state
                [p nx ny] = p_yi2_given_xi1xi2(po{i-1}(k,1), po{i-1}(k,2), temp4, r, img);
                temp1(k) = M(i-1,k) + p;
                temp2(k,:) = [nx,ny];
                temp3(k) = temp4;
            end
            [tempM(j) tempA(j)] = max(temp1);
            tempPosition(j,:) = temp2(tempA(j),:);
            tempAngle(j) = temp3(tempA(j));
        end
        M(i,:) = tempM;                                 % not essential to save every M
        A(i,:) = tempA;
        po{i} = tempPosition;
        ang(i,:) = tempAngle;    
    end
end

% find node which maximize the cost function
for i = numNode:-1:1
    if i == numNode
        [logP maxIdx] = max(M(i-1,:));
        position(i,:) = [po{i-1}(maxIdx,1) po{i-1}(maxIdx,2)];
    elseif i == 1
        maxIdx = A(i,maxIdx);
        position(i,:) = [initR*cos(initState(maxIdx))+initialX initR*sin(initState(maxIdx))+initialY];
    else
        maxIdx = A(i,maxIdx);
        position(i,:) = [po{i-1}(maxIdx,1) po{i-1}(maxIdx,2)];
    end
end

