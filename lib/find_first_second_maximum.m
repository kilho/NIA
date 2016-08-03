function [firIdx, secIdx, secFlag] = find_first_second_maximum(prob)

% find 2 local maximum

% parameter setting
nmsMargin = floor(length(prob)*3/8);
ratioThre = 0.5;

thre = (max(prob)+min(prob))*ratioThre;

prob(prob < thre) = -inf;
[~, firIdx] = max(prob);

if firIdx + nmsMargin > length(prob)
    endPt = length(prob);
else
    endPt = firIdx+nmsMargin;
end
if firIdx - nmsMargin < 1
    startPt = 1;
else
    startPt = firIdx-nmsMargin;
end
prob(startPt:endPt) = -inf;

[maxVal, secIdx] = max(prob);

if maxVal == -inf
    secFlag = 0;
else
    secFlag = 1;
end