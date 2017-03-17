%Missile Detection and Interception system.
%Prasoon Dhaneshwar
%M.Tech. Electronic Systems Design(Embedded Systems)
%IIIT Bangalore

%This code also includes two files: distance.m(to calculate distance between missile and interceptor)
%and computemove.m(to compute the next move of interceptor)


%Initialization
%Start Serial communication
s = serial('COM8');
fopen(s);

%Red color to detect missile, green and blue for interceptor.
redThresh = 0.1;    % Default Threshold for red detection 0.24
greenThresh = 0.03; % Default  Threshold for green detection 0.05
blueThresh = 0.1;   % Default Threshold for blue detection 0.15

%Setting video object
vidDevice = imaq.VideoDevice('winvideo', 1, 'YUY2_800x600', 'ROI', [1 1 800 600],'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice); % Acquire input video property

hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
                                'CentroidOutputPort', true, 'BoundingBoxOutputPort', true', 'MinimumBlobArea', 600, 'MaximumBlobArea', 3000, ...
                                'MaximumCount', 10);

hshapeinsBox = vision.ShapeInserter('BorderColorSource', 'Input port', ... % Set box handling
                                        'Fill', true, 'FillColorSource', 'Input port', 'Opacity', 0.4);
htextinsRed = vision.TextInserter('Text', 'Red: Missile   : %2d', ... % Set text for number of blobs
                                    'Location',  [5 2], ...
                                    'Color', [1 0 0], ... // red color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);
htextinsGreen = vision.TextInserter('Text', 'Green : Interceptor : %2d', ... % Set text for number of blobs
                                    'Location',  [5 18], ...
                                    'Color', [0 1 0], ... // green color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);
htextinsBlue = vision.TextInserter('Text', 'Blue  : %2d', ... % Set text for number of blobs
                                    'Location',  [5 34], ...
                                    'Color', [0 0 1], ... // blue color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);
htextinsCent = vision.TextInserter('Text', '+      X:%4d, Y:%4d', ... % set text for centroid
                                    'LocationSource', 'Input port', ...
                                    'Color', [1 1 0], ... // yellow color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
                                'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);

%Frame number initialization                            
nFrame = 0; 

%Write into video
v= VideoWriter('newfile.avi');  
v.FrameRate = 10;  % Default 30
v.Quality = 75;    % Default 75
open(v);


%% Processing Loop
while(nFrame < 80)
    
    rgbFrame = step(vidDevice); % Acquire single frame
    %rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying
    
    diffFrameRed = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
    diffFrameRed = medfilt2(diffFrameRed, [3 3]); % Filter out the noise by using median filter
    binFrameRed = im2bw(diffFrameRed, redThresh); % Convert the image into binary image with the red objects as white
    
    diffFrameGreen = imsubtract(rgbFrame(:,:,2), rgb2gray(rgbFrame)); % Get green component of the image
    diffFrameGreen = medfilt2(diffFrameGreen, [3 3]); % Filter out the noise by using median filter
    binFrameGreen = im2bw(diffFrameGreen, greenThresh); % Convert the image into binary image with the green objects as white
    
    diffFrameBlue = imsubtract(rgbFrame(:,:,3), rgb2gray(rgbFrame)); % Get blue component of the image
    diffFrameBlue = medfilt2(diffFrameBlue, [3 3]); % Filter out the noise by using median filter
    binFrameBlue = im2bw(diffFrameBlue, blueThresh); % Convert the image into binary image with the blue objects as white
    
    [centroidRed, bboxRed] = step(hblob, binFrameRed); % Get the centroids and bounding boxes of the red blobs
    %centroidRed = uint16(centroidRed); % Convert the centroids into Integer for further steps (LINE 84)
    
    [centroidGreen, bboxGreen] = step(hblob, binFrameGreen); % Get the centroids and bounding boxes of the green blobs
    %centroidGreen = uint16(centroidGreen); % Convert the centroids into Integer for further steps(LINE 89)
    
    [centroidBlue, bboxBlue] = step(hblob, binFrameBlue); % Get the centroids and bounding boxes of the blue blobs
    %centroidBlue = uint16(centroidBlue); % Convert the centroids into Integer for further steps (LINE 94)
    
    rgbFrame(1:50,1:90,:) = 0; % put a black region on the output stream
    vidIn = step(hshapeinsBox, rgbFrame, bboxRed, single([1 0 0])); % Instert the red box
    vidIn = step(hshapeinsBox, rgbFrame, bboxGreen, single([0 1 0])); % Instert the green box
    vidIn = step(hshapeinsBox, vidIn, bboxBlue, single([0 0 1])); % Instert the blue box
 
    
    for object = 1:1:length(bboxRed(:,1)) % Write the corresponding centroids for red
        centXRed = centroidRed(object,1); centYRed = centroidRed(object,2);
        vidIn = step(htextinsCent, vidIn, [uint16(centXRed) uint16(centYRed)], [uint16(centXRed)-6 uint16(centYRed)-9]); 
    end
    
    for object = 1:1:length(bboxGreen(:,1)) % Write the corresponding centroids for green
        centXGreen = centroidGreen(object,1); centYGreen = centroidGreen(object,2);
        vidIn = step(htextinsCent, vidIn, [uint16(centXGreen) uint16(centYGreen)], [uint16(centXGreen)-6 uint16(centYGreen)-9]); 
    end
    
    for object = 1:1:length(bboxBlue(:,1)) % Write the corresponding centroids for blue
        centXBlue = centroidBlue(object,1); centYBlue = centroidBlue(object,2);
        vidIn = step(htextinsCent, vidIn, [uint16(centXBlue) uint16(centYBlue)], [uint16(centXBlue)-6 uint16(centYBlue)-9]); 
    end
    
    vidIn = step(htextinsRed, vidIn, uint8(length(bboxRed(:,1)))); % Count the number of red blobs
    vidIn = step(htextinsGreen, vidIn, uint8(length(bboxGreen(:,1)))); % Count the number of green blobs
    vidIn = step(htextinsBlue, vidIn, uint8(length(bboxBlue(:,1)))); % Count the number of blue blobs
    step(hVideoIn, vidIn); % Output video stream
    nFrame = nFrame+1;
    
    %Computation for next move.
    if(mod(nFrame,5) == 0)
      computemove(centXRed,centYRed,centXBlue,centYBlue,centXGreen,centYGreen,s);
    end
    
    %if missile reaches a certain smaller threshold
    distanceB = distance(centXRed,centYRed, centXGreen, centYGreen );
   if distanceB < 80
        break;
    end
  
  writeVideo(v,vidIn);
end
%Closing VideoWriter object
close(v);



%% Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);

%Closing serial communication
fwrite(s,'0');
fclose(s);
instrreset;

%clear all;
%clc;