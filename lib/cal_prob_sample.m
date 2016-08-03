function [prob, posX, posY, ang] = cal_prob_sample(startP, startA, r, numState, resol, img, height, width)
% calculate next sample probability for each sample
% startP = [x1, y1; x2, y2;...]

numSample = size(startP,1);
prob = zeros(numSample, numState);
posX = zeros(numSample, numState);
posY = zeros(numSample, numState);
ang = zeros(numSample, numState);

halfNumState = floor(numState/2)+1;


for i = 1:numSample
    if startP(i,2) <=0 || startP(i,2)>height || startP(i,1)<=0 || startP(i,1)>width
        prob(i,:) = -inf;
        posX(i,:) = startP(i,1);
        posY(i,:) = startP(i,2);
    else
        for j = 1:numState
            tempAng = startA(i)+resol*(j-halfNumState);

            x = round(r*cos(tempAng)+startP(i,1));
            y = round(r*sin(tempAng)+startP(i,2));
            posX(i,j) = x; posY(i,j) = y;
            ang(i,j) = tempAng;

            if y<=0 || y>height || x<=0 || x>width
                prob(i,j) = -inf;
            else
                for k = 1:r
                    xt = round(k*cos(tempAng)+startP(i,1));
                    yt = round(k*sin(tempAng)+startP(i,2));
                    prob(i,j) = prob(i,j) + log(img(yt,xt));
                end
            end
        end
    end
end
    