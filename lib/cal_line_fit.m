function [likelihood, dir]= cal_line_fit(patch, pixelThre, sizeWindow, thre1, mask)

binPatch = (patch < (patch(ceil(sizeWindow/2), ceil(sizeWindow/2)) + pixelThre))...
    & (patch > (patch(ceil(sizeWindow/2), ceil(sizeWindow/2)) - pixelThre));