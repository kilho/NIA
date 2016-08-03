function [unitary, grad] = find_uni_grad(likelihood, halfWinSize, numState)

[height, width] = size(likelihood);
unitary = zeros(height, width);

for i = halfWinSize+1:height-halfWinSize
    for j = halfWinsize+1:width-halfWinSize
        tempImg = likelihood(i-halfWinSize:i+halfWinSize, j-halfWinSize:j+halfWinSize);
        
        
    end
end
        



