% Detection and Recognition of nucleus and axon
% Kilho Son @ Brown university
% Jan. 21 2013

clear all
close all
clc

disp('Hidden Markov Model(HMM) + Dynamic Programming for tracing neurites')

%% constant
addpath('lib')
dataFolder = 'data';                            % folder including data

fileNames = dir(dataFolder);

%% parameters
% parameter for detecting nucleus
kernelSize      = 80;               % size of LoG filter (unit: pixel) (depend on the scale of image)
kernelScale     = 20;               % scale of LoG filter (unit: pixel) (depend on the scale of image)
threRatio       = 0.5;              % threshod for detecting cell (not critical parameter)
levelsetR       = 40;               % parameter for level set (refer to "Distance Regularized Level Set Evolution and Its Application to Image Segmentation", in IEEE TRANSACTIONS ON IMAGE PROCESSING)        

minSizeCell     = kernelSize/2;     % minimum size of cell


% parameters for detecting initial point of axon
initR           = 70;               % distance between the origin and the first node (unit: pixel) (depend on the scale of image)
initNumState    = 72;               % number of state for the first node (not critical parameter)
boxFilterSize   = 3;                % boxfilter size (not critical parameter)
threRatioInit   = 0.45;             % threshold for detecting initial point of axon ( not critical parameter)
NMSsize         = 5;                % non maximum supression parameter (not critical parameter)

initState       = 0:2*pi/initNumState:2*pi-2*pi/initNumState; % quantization

% parameter find axon
range           = pi*2/3;           % range of angle for next node (not critical parameter)
numState        = 30+1;             % number of state for the other nodes (not critical parameter)
r               = 15;               % length between nodes (unit: pixel) (depend on the image scale)
numNode         = 100;              % number of node including the first node (r*numNode is the maximimum length that a axon can have)
numDisconnectThre = 4;              % parameter for disconnecting axon tracing (not critical parameter)
threDisconnect  = 0.9;              % parameter for disconnecting axon tracing ( if the tracing finishes earlier than expected, reduce this value)

winSize         = r*3;              % window to find local median
nmsMargin       = floor(numState/2);% non maximum supression for generating sequence sampling

%% variables
% define structure for saving results
rst = struct( 'nucleusCenter_', [] , 'boundaryNucleus_', [], 'axonPosition_', [], 'maxIdx_', []);
rst = repmat(rst,length(fileNames)-2,1);

%%%%%%%%%%%%%%%%% let's run the algorithm for all images %%%%%%%%%%%%%%%
for i = 1:length(fileNames)-2 % for all images
    %% load data
    idx = i+2;
    disp(['Processing image "' fileNames(idx).name '" / ' num2str(length(fileNames)-2) ' files'])
    
    inputImg = imread([dataFolder '/' fileNames(idx).name]);
    inputImg = inputImg(:,:,2);
    inputImg1 = double(inputImg);
    inputImg = inputImg1/(max(inputImg1(:)));
    [height, width] = size(inputImg);

    tic
    %% nucleus detection (blob detector, LOG)
    disp('Start nucleus detection')
    [x, y, boundaryNucleus] = find_nucleus_boundary(inputImg, inputImg1, kernelSize, kernelScale, threRatio, minSizeCell, levelsetR);
    disp('Done nucleus detection')
    
    %% axon detector 
    disp('Start neurite tracing')
    numNeuron = length(x);
    axonPosition = cell(numNeuron,1);
    
    % calculate likelihood probability (we choosed box filtered image as a likelihood probability but you can use gradient image of Gaussian filtered image as a likelihood)
    boxFilter = ones(boxFilterSize);
    boxFilter = boxFilter/(boxFilterSize^2);
    boxImg = conv2(inputImg, boxFilter, 'same');
    likelihood = boxImg; 
    
    % find medium value of the image
    medianValue = median(likelihood(:));

    % for all nucleus, find starting points by threholding + NMS
    for j = 1:numNeuron

        initialX = x(j);
        initialY = y(j);
        [startX, startY, startAngle] = find_start_point_tracing(initialX, initialY, initNumState, initState, initR, likelihood, threRatioInit, NMSsize, height, width);
        
        % for all the starting point in each nucleus, run tracing algorithm
        axonPosition{j} = cell(length(startX),1);
        for k = 1:length(startX)
            [position, flag, pixelVal, med]= trace_HMM(startX(k), startY(k), startAngle(k), numState, r, numNode, range, likelihood, medianValue, 0.05, numDisconnectThre, winSize, threDisconnect, [initialX initialY]);
            temp = xor([flag; false],[true; flag]);
            idx = find(temp == true);
            axonPosition{j}{k} = position(1:idx-2,:);
            
            startAxon = find_start_axon(initialX, initialY, startX(k), startY(k), boundaryNucleus, initR);
            axonPosition{j}{k} = [startAxon; axonPosition{j}{k}];
        end
    end
    
    % find longest one (axon) among the tracings
    maxIdx = find_longest_tracing(numNeuron, axonPosition);
    
    % save result
    rst(i) = struct( 'nucleusCenter_',[x,y] , 'boundaryNucleus_', uint8(boundaryNucleus), 'axonPosition_', {axonPosition}, 'maxIdx_', maxIdx);
    
    disp('Done neurite tracing')
    toc
    disp('--------------------------------------------')

end
disp('DONE !!')

%% display result and save final result
finalAngLen = cell(length(fileNames)-2,1);
flagIsNeuron = cell(length(fileNames)-2,1);
for i = 1:length(fileNames)-2
    %load data
    idx = i+2;
    display_results(dataFolder, fileNames, idx, i, rst, finalAngLen, flagIsNeuron);
end