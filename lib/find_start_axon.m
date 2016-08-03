function startAxon = find_start_axon(initialX, initialY, startX, startY, boundaryNecleus, initR)
flag = 0;
for i = 1:initR
    posX = round((initialX*(initR-i)+startX*i)/initR);
    posY = round((initialY*(initR-i)+startY*i)/initR);
    if boundaryNecleus(posY,posX) > 0 
        startAxon = [posX posY];
        flag = 1;
        break
    end
end

if flag == 0
    startAxon = [startX, startY];
end