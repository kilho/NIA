function finalPosition = trace_FCM(startP, startA, numState, r, numNode, range, img,  numDisconnectThre, winSize, threDisconnect, numSample, nmsMargin, initial, initR)
%% variant greedy algorithm for tracing dendrites

nonFlag = 0;
finalPosition = zeros(numNode,2);              % x, y
% finalProb = zeros(numNode,1);
%ignoreNum = 20;
%flag(1:ignoreNum) = true;
resol = range/(numState-1);
[height, width] = size(img);

% flag for active sample
activeSample = true(numSample,1);

% generate sequence samples
seqSampleX = zeros(numSample,numNode); % sequence samples X
seqSampleY = zeros(numSample,numNode); % sequence samples Y

% initialize the sample
seqSampleX(1,1) = startP(1);
seqSampleY(1,1) = startP(2);

for i = 2:numNode
    if i == 2
        curP = startP;
        curA = startA;
    end
    
    % calculate probability for each sample
    [prob, posX, posY, ang, activeSample] = cal_prob_sample_2nd(curP, curA, r, numState, resol, img, height, width, activeSample);
    count = 1;
    for j = 1:size(prob,1) % for all samples
        if activeSample(j) == 1
            [firIdx, secIdx, secFlag] = find_first_second_maximum_2nd(prob(j,:), numState, nmsMargin);

            % if there is overlap between line de-active the line
            if min(sqrt((seqSampleX(j,1:i-1)-posX(j,firIdx)).^2 + (seqSampleY(j,1:i-1)-posY(j,firIdx)).^2)) < r-2 || sqrt((initial(1)-posX(j,firIdx))^2+(initial(2)-posY(j,firIdx))^2) < initR
                activeSample(j) = 0;
            else
                seqSampleX(j,i) = posX(j,firIdx);
                seqSampleY(j,i) = posY(j,firIdx);
            end
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             figure(1)
%             imshow(img)
%             hold on
%             plot(posX(j,:), posY(j,:), '.')
%             plot(curP(j,1), curP(j,2), 'r.')
%             plot(seqSampleX(j,i), seqSampleY(j,i),'r.')
%             if secFlag == 1
%                 plot(posX(j,secIdx), posY(j,secIdx),'r.')
%             end
%             hold off
%             figure(2)
%             plot(prob(j,:))
% %             pause
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            curA(j) = ang(j,firIdx);
            curP(j,:) = [posX(j,firIdx), posY(j,firIdx)];

            % if there is new path, generate new sample
            if secFlag == 1 && size(prob,1)+count <= numSample

                newIdx = size(prob,1)+count;
                seqSampleX(newIdx, 1:i-1) = seqSampleX(j,1:i-1);
                seqSampleY(newIdx, 1:i-1) = seqSampleY(j,1:i-1);
                
                % if there is overlap, de-active the line
                if min(sqrt((seqSampleX(newIdx,1:i-1)-posX(j,secIdx)).^2 + (seqSampleY(newIdx,1:i-1)-posY(j,secIdx)).^2)) < r-2 || sqrt((initial(1)-posX(j,secIdx))^2+(initial(2)-posY(j,secIdx))^2) < initR
                    activeSample(newIdx) = 0;
                else
                    seqSampleX(newIdx, i) = posX(j,secIdx); 
                    seqSampleY(newIdx, i) = posY(j,secIdx);
                end
                
                curA(newIdx) = ang(j,secIdx);
                curP(newIdx,:) = [posX(j,secIdx), posY(j,secIdx)];
                count = count+1;
            end
        end
    end
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(10)
% for i = 1: numSample
%     imshow(imcomplement(img))
%     hold on
%     plot(seqSampleX(i,seqSampleX(i,:) ~= 0), seqSampleY(i,seqSampleY(i,:) ~= 0),'r')
%     plot(seqSampleX(i,seqSampleX(i,:) ~= 0), seqSampleY(i,seqSampleY(i,:) ~= 0),'r*', 'MarkerSize', 3)
%     hold off
%     pause
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maxSampleLength = 0;
for samIdx = 1:numSample
    if seqSampleX(samIdx,1) ~= 0  % if the sample has position 0, don't care about it
        temp11 = seqSampleX(samIdx,:);
        temp11 = temp11(temp11 ~= 0);
        temp22 = seqSampleY(samIdx,:);
        temp22 = temp22(temp22 ~= 0);
        if length(temp11) == length(temp22)
            position = [temp11' temp22'];
        elseif length(temp11) > length(temp22)
            tN = length(temp11)-length(temp22);
            temp22 = [temp22 zeros(1,tN)];
            position = [temp11' temp22'];
        else
            tN = length(temp22)-length(temp11);
            temp11 = [temp11 zeros(1,tN)];
            position = [temp11' temp22'];
        end
            
        
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         figure(100)
%         imshow(imcomplement(img))
%         hold on
%         plot(position(:,1), position(:,2),'r', 'LineWidth',1, 'MarkerSize', 3);
%         plot(position(:,1), position(:,2),'r*', 'MarkerSize', 3);
%         hold off
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        realNumNode = length(temp11);
        intensitySeries = zeros(realNumNode-1, r);
        flagIntensitySeries = double(zeros(realNumNode-1,r));
        medianValueSeries = zeros(realNumNode-1,1);
        flag = false(realNumNode-1,1); 
        for i = 1:realNumNode-1
            point1 = position(i,:);
            point2 = position(i+1,:);
            [intensitySeries(i,:), medianValueSeries(i)] = get_intensity_median(point1, point2, r, winSize, img, height, width);
            flagIntensitySeries(i,:) = double(intensitySeries(i,:) > medianValueSeries(i));
        end
        for i = 1:realNumNode-numDisconnectThre
            temp1 = flagIntensitySeries(i:i+numDisconnectThre-1,:)';
            temp = temp1(:);
            if sum(temp) > r*threDisconnect*numDisconnectThre;
                flag(i) = true;
            else
                break
            end
        end
        flag = [true; flag];
        
        temp10 = xor([flag; false],[true; flag]);
        idx = find(temp10 == true,1);
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         figure(100)
%         imshow(imcomplement(img))
%         hold on
%         plot(position(1:idx-1,1), position(1:idx-1,2),'r', 'LineWidth',1, 'MarkerSize', 3);
%         plot(position(1:idx-1,1), position(1:idx-1,2),'r*', 'MarkerSize', 3);
%         hold off
%         pause
% %         export_fig(sprintf('fig%d.png', samIdx));
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if maxSampleLength < idx-1
            finalPosition = position(1:idx-1,:);
%             pixelVal = intensitySeries';
%             pixelVal = pixelVal(:);
%             med = medianValueSeries;
            maxSampleLength = idx-1;
            nonFlag = 1;
        end
    end
end

if nonFlag == 0
    finalPosition = [];
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(1000)
% plot(pixelVal,'.');
% hold on
% for kkk = 1:length(med)
%     if kkk < idx
%         plot([r*(kkk-1) r*kkk], [med(kkk) med(kkk)],'r')
%     else
%         plot([r*(kkk-1) r*kkk], [med(kkk) med(kkk)],'m')
%     end
%     plot([r*(kkk-1) r*kkk], [0.5*flag(kkk+1) 0.5*flag(kkk+1)],'k')
% end
% axis([0 2000 0 2])
% hold off
% figure(2000)
% imshow(likelihood)
% hold on
% plot(initialX, initialY, '.');
% plot(position(1:idx-1,1), position(1:idx-1,2),'r');
% plot(position(idx:end,1), position(idx:end,2));
% %             text(position(1:idx-1,1), position(1:idx-1,2), num2str((1:idx-1)'),'Color', [1 0 0]);
% hold off
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%