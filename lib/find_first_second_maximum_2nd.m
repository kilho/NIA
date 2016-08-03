function [firIdx, secIdx, secFlag] = find_first_second_maximum_2nd(prob, numState, nmsMargin)

% find 2 local maximum

% parameter setting
% nmsMargin = floor(numState*3/8);
ratioThre = 0.5;

thre = (max(prob)+min(prob))*ratioThre;

prob(prob < thre) = -inf;
[~, firIdx] = max(prob);
firIdx = ceil(firIdx/numState);

if firIdx + nmsMargin > numState
    endPt = numState;
else
    endPt = firIdx+nmsMargin;
end
if firIdx - nmsMargin < 1
    startPt = 1;
else
    startPt = firIdx-nmsMargin;
end
prob((startPt-1)*numState + 1:endPt*numState) = -inf;

[maxVal, secIdx] = max(prob);
secIdx = ceil(secIdx/numState);

if maxVal == -inf
    secFlag = 0;
else
    secFlag = 1;
end