function hierImg = gen_hierarchical_image(inputImg)

numHier = 5;
hierImg = cell(numHier,1);

for i = 1:numHier
    if i == 1
        hierImg{1} = inputImg;
    else
        
        hierImg{i} = imresize(hierImg{i-1},0.5);
    end
end

for i = 1:numHier
    imshow(hierImg{i})
    pause
end