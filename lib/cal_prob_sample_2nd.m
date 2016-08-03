function [prob, posX, posY, ang, activeSample] = cal_prob_sample_2nd(startP, startA, r, numState, resol, img, height, width, activeSample)
% calculate next sample probability for each sample
% startP = [x1, y1; x2, y2;...]

numSample = size(startP,1);
prob = zeros(numSample, numState^2);
posX = zeros(numSample, numState);
posY = zeros(numSample, numState);
ang = zeros(numSample, numState);

halfNumState = floor(numState/2)+1;

temp = zeros(numState);

for i = 1:numSample % for each sample
    if startP(i,2) <=5 || startP(i,2)>=height-5 || startP(i,1)<=5 || startP(i,1)>=width-5
        prob(i,:) = -inf;
        posX(i,:) = startP(i,1);
        posY(i,:) = startP(i,2);
        activeSample(i) = 0;
    else
        for j = 1:numState % for the first direction
            tempAng1 = startA(i)+resol*(j-halfNumState);
            x1 = round(r*cos(tempAng1)+startP(i,1));
            y1 = round(r*sin(tempAng1)+startP(i,2));
            posX(i,j) = x1; posY(i,j) = y1;
            ang(i,j) = tempAng1;
            
            if y1<=1 || y1>=height || x1<=1 || x1>=width
                temp(:,j) = -inf;
            else
                prob_1nd = 0;
                for k = 1:r
                    xt = round(k*cos(tempAng1)+startP(i,1));
                    yt = round(k*sin(tempAng1)+startP(i,2));
                    prob_1nd = prob_1nd + log(img(yt,xt));
                end
                for jj = 1:numState
                    tempAng2 = tempAng1+resol*(jj-halfNumState);
                    x2 = round(r*cos(tempAng2))+x1;
                    y2 = round(r*sin(tempAng2))+y1;
                    if y2<=1 || y2 >= height || x2 <= 1 || x2 >= width
                        temp(jj,j) = -inf;
                    else
                        temp(jj,j) = prob_1nd;
                        for k = 1:r
                            xt = round(k*cos(tempAng2)+x1);
                            yt = round(k*sin(tempAng2)+y1);
                            temp(jj,j) = temp(jj,j) + log(img(yt,xt));
                        end                      
                    end
                end
            end
        end
        prob(i,:) = temp(:)';
    end
end
    