function maxIdx = find_longest_tracing(numNeuron, axonPosition)

maxIdx = zeros(numNeuron,1);
for j = 1:numNeuron
    if length(axonPosition{j}) == 1
        maxIdx(j) = 1;
    else
        count = 0;
        maxCount = 0;
        for k = 1:length(axonPosition{j})
            count = size(axonPosition{j}{k},1);
            if count > maxCount
                maxIdx(j) = k;
                maxCount = count;
            end
        end
    end
end