function finalPosition = particle_filter_with_initial(startP, startA, numState, r, numNode, range, img,  numDisconnectThre, winSize, threDisconnect, numSample)

nonFlag = 0;
finalPosition = zeros(numNode,2);              % x, y
% finalProb = zeros(numNode,1);
%ignoreNum = 20;
%flag(1:ignoreNum) = true;
resol = range/(numState-1);
[height, width] = size(img);

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
    [prob, posX, posY, ang] = cal_prob_sample(curP, curA, r, numState, resol, img, height, width);
    count = 1;
    for j = 1:size(prob,1) % for all samples
        
        [firIdx, secIdx, secFlag] = find_first_second_maximum(prob(j,:));
        seqSampleX(j,i) = posX(j,firIdx);
        seqSampleY(j,i) = posY(j,firIdx);
        
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         figure(1)
%         imshow(img)
%         hold on
%         plot(posX(j,:), posY(j,:), '.')
%         plot(curP(j,1), curP(j,2), 'r.')
%         plot(seqSampleX(j,i), seqSampleY(j,i),'r.')
%         if secFlag == 1
%             plot(posX(j,secIdx), posY(j,secIdx),'r.')
%         end
%         hold off
%         figure(2)
%         plot(prob(j,:))
% %         pause
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        curA(j) = ang(j,firIdx);
        curP(j,:) = [posX(j,firIdx), posY(j,firIdx)];
        
        % if there is new path, generate new sample
        if secFlag == 1 && size(prob,1)+count <= numSample
            
            newIdx = size(prob,1)+count;
            seqSampleX(newIdx, 1:i-1) = seqSampleX(j,1:i-1);
            seqSampleY(newIdx, 1:i-1) = seqSampleY(j,1:i-1);
            seqSampleX(newIdx, i) = posX(j,secIdx); 
            seqSampleY(newIdx, i) = posY(j,secIdx);
            
            curA(newIdx) = ang(j,secIdx);
            curP(newIdx,:) = [posX(j,secIdx), posY(j,secIdx)];
            count = count+1;
        end
    end
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(10)
% for i = 1: numSample
%     imshow(img)
%     hold on
%     plot(seqSampleX(i,:), seqSampleY(i,:))
%     hold off
%     pause
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxSampleLength = 0;
for samIdx = 1:numSample
    if seqSampleX(samIdx,1) ~= 0  % if the sample has position 0, don't care about it
        position = [seqSampleX(samIdx,:)' seqSampleY(samIdx,:)'];
        intensitySeries = zeros(numNode-1, r);
        flagIntensitySeries = double(zeros(numNode-1,r));
        medianValueSeries = zeros(numNode-1,1);
        flag = false(numNode-1,1); 
        for i = 1:numNode-1
            point1 = position(i,:);
            point2 = position(i+1,:);
            [intensitySeries(i,:), medianValueSeries(i)] = get_intensity_median(point1, point2, r, winSize, img, height, width);
            flagIntensitySeries(i,:) = double(intensitySeries(i,:) > medianValueSeries(i));
        end
        for i = 1:numNode-numDisconnectThre
            temp1 = flagIntensitySeries(i:i+numDisconnectThre-1,:)';
            temp = temp1(:);
            if sum(temp) > r*threDisconnect*2;
                flag(i) = true;
            else
                break
            end
        end
        flag = [true; flag];
        
        temp10 = xor([flag; false],[true; flag]);
        idx = find(temp10 == true,1);
        if maxSampleLength < idx-2
            finalPosition = position(1:idx-2,:);
            pixelVal = intensitySeries';
            pixelVal = pixelVal(:);
            med = medianValueSeries;
            maxSampleLength = idx-2;
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