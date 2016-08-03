function [intensity, medianValue] = get_intensity_median(point1, point2, resol, winSize, img, height, width)

% find median value of the window
centerPoint = [round((point1(1)+point2(1))/2), round((point1(2)+point2(2))/2)];
maxX = centerPoint(1) + winSize;
minX = centerPoint(1) - winSize;
maxY = centerPoint(2) + winSize;
minY = centerPoint(2) - winSize;

if maxX > width
    maxX = width;
end
if minX < 1
    minX = 1;
end
if maxY > height
    maxY = height;
end
if minY < 1
    minY = 1;
end

subImg = img(minY:maxY, minX:maxX);
medianValue = median(subImg(:));

% find series of intensity
intensity = zeros(resol,1);
if point1(1) < 1 || point1(2) < 1 || point1(1) > width || point1(2) > height
    intensity(1) = -inf;
else
    intensity(1) = img(point1(2),point1(1));
end
for i = 1:resol-1
    posX = (point1(1)*(resol-i)+point2(1)*i)/resol;
    posY = (point1(2)*(resol-i)+point2(2)*i)/resol;

    posXD = floor(posX);
    posXU = ceil(posX);
    posYD = floor(posY);
    posYU = ceil(posY);
        
    if posXD < 1 || posXD > width || posXU < 1 || posXU > width || posYD < 1 || posYD > height || posYU < 1 || posYU > height
        intensity(i+1) = -inf;
    else
        tempIntensity1 = img(posYD, posXD) + (posY-posYD)*(img(posYU, posXD) - img(posYD, posXD));
        tempIntensity2 = img(posYD, posXU) + (posY-posYD)*(img(posYU, posXU) - img(posYD, posXU));

        intensity(i+1) = tempIntensity1 + (posX-posXD)*(tempIntensity2-tempIntensity1);
    end
end
    