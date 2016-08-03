function display_results(dataFolder, fileNames, idx, i, rst, finalAngLen, flagIsNeuron)

inputImg = imread([dataFolder '/' fileNames(idx).name]);
fileNames(idx).name
inputImg = inputImg(:,:,2);
inputImg1 = double(inputImg);
inputImg = inputImg1/(max(inputImg1(:)));

figure(i)
imshow(imcomplement(inputImg))
title('Input')
figure(1000+i)
imshow(imcomplement(inputImg))
title('Output')

hold on
contour(rst(i).boundaryNucleus_, [0,0], 'r', 'LineWidth', 2);

finalAngLen{i} = zeros(size(rst(i).nucleusCenter_,1),2);
flagIsNeuron{i} = zeros(size(rst(i).nucleusCenter_,1),1);
for j = 1:size(rst(i).nucleusCenter_,1)
    plot(rst(i).nucleusCenter_(j,1),rst(i).nucleusCenter_(j,2),'g.', 'MarkerSize', 20)

    for k = 1:length(rst(i).axonPosition_{j})
        if k == rst(i).maxIdx_(j)
            % calculate angle
            lenX = rst(i).axonPosition_{j}{k}(end,1)-rst(i).nucleusCenter_(j,1);
            lenY = rst(i).axonPosition_{j}{k}(end,2)-rst(i).nucleusCenter_(j,2);
            finalAngLen{i}(j,1) = -atan2d(lenY,lenX);% angle

            % calculate length
            if size(rst(i).axonPosition_{j}{k},1) == 1
                finalAngLen{i}(j,2) =  0;
            else
                tempX1 = rst(i).axonPosition_{j}{k}(2:end,1);
                tempX2 = rst(i).axonPosition_{j}{k}(1:end-1,1);

                tempY1 = rst(i).axonPosition_{j}{k}(2:end,2);
                tempY2 = rst(i).axonPosition_{j}{k}(1:end-1,2);

                finalAngLen{i}(j,2) =  sum(sqrt((tempX1-tempX2).^2+(tempY1-tempY2).^2));% length
            end
            if finalAngLen{i}(j,2) > 70

                flagIsNeuron{i}(j) = 1;
                plot(rst(i).axonPosition_{j}{k}(:,1), rst(i).axonPosition_{j}{k}(:,2),'r', 'LineWidth',1, 'MarkerSize', 3);
                plot(rst(i).axonPosition_{j}{k}(:,1), rst(i).axonPosition_{j}{k}(:,2),'r*', 'MarkerSize', 3);

                text(rst(i).axonPosition_{j}{k}(end,1)-240, rst(i).axonPosition_{j}{k}(end,2), ['A:' num2str(round(finalAngLen{i}(j,1))) '\circ' ', L:' num2str(round(finalAngLen{i}(j,2)*0.3125*10)/10) '\mu' 'm'] ,...
                    'Color', [0 0 0], 'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'FontSize', 40)
                text(rst(i).nucleusCenter_(j,1),rst(i).nucleusCenter_(j,2),['N' num2str(j)], 'FontWeight', 'bold', 'VerticalAlignment', 'top', 'Color', [0 0 0], 'FontSize', 40 )
            end
        else
            % calculate angle
            lenX = rst(i).axonPosition_{j}{k}(end,1)-rst(i).nucleusCenter_(j,1);
            lenY = rst(i).axonPosition_{j}{k}(end,2)-rst(i).nucleusCenter_(j,2);
            ang =  -atan2d(lenY,lenX);% angle

            % calculate length
            if size(rst(i).axonPosition_{j}{k},1) == 1
                len =  0;
            else
                tempX1 = rst(i).axonPosition_{j}{k}(2:end,1);
                tempX2 = rst(i).axonPosition_{j}{k}(1:end-1,1);

                tempY1 = rst(i).axonPosition_{j}{k}(2:end,2);
                tempY2 = rst(i).axonPosition_{j}{k}(1:end-1,2);

                len =  sum(sqrt((tempX1-tempX2).^2+(tempY1-tempY2).^2));% length
            end                

            if len >70
                plot(rst(i).axonPosition_{j}{k}(:,1), rst(i).axonPosition_{j}{k}(:,2),'b', 'LineWidth',1, 'MarkerSize', 3);
                plot(rst(i).axonPosition_{j}{k}(:,1), rst(i).axonPosition_{j}{k}(:,2),'b*', 'MarkerSize', 3);

            end
        end
    end
end