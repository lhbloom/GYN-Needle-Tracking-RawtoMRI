clc; clear;
% Specify the input raw file, output folder, and image dimensions

inputFile = '/Users/Lindsey/Downloads/Needle-Tracking/MR Deformable Reg/Final Experiment/Deformation6_320_320_192.raw'; % Path to .raw file
outputFolder = '/Users/Lindsey/Downloads/Needle-Tracking/MR Deformable Reg/Final Experiment/DICOM Files'; % Path to output DICOM files
imageWidth = 320;   % Image width
imageHeight = 320;  % Image height
numSlices = 192;     % Number of slices

slicethickness= 1;    %change this to 0.1... may have to change the dimensions as well

% Open the raw file for reading
%% 
fileID = fopen(inputFile, 'r');

% Check if the file is successfully opened
if fileID == -1
    error('Error opening the raw file.');
end

% Read the raw image data
rawData = fread(fileID, imageWidth * imageHeight * numSlices, '*uint16');

% Close the file
fclose(fileID);

% Reshape the data into a 3D matrix
imageData = reshape(rawData, [imageWidth, imageHeight, numSlices]);
imageData_rot= imrotate(imageData, 270);
imageData_flip= fliplr(imageData_rot);
imageData_flipped= flip(imageData_flip, 3);

% Scale the image intensities
imageData_flipped = imageData_flipped * 40;


% UIDs 
SOPclassUID= '1.2.840.10008.5.1.4.1.1.4';  % UID for MR Image Storage
StudyInstanceUID = [SOPclassUID, '.', num2str(randi(1000,1,1)), '.', num2str(randi(100,1,1))];
SeriesInstanceUID = [SOPclassUID, '.', num2str(randi(1000,1,1)), '.', num2str(randi(100,1,1))];
SOPInstanceUID = [SOPclassUID, '.', num2str(randi(1000,1,1)), '.', num2str(randi(100,1,1))];


%%
% Loop over each slice and save it as a DICOM file
for sliceIndex = 1:numSlices
    % Extract the current slice
    currentSlice = imageData_flipped(:, :, sliceIndex);

    % Create a DICOM info structure 
    dicomInfo = struct();
    dicomInfo.Width = imageWidth;
    dicomInfo.Height = imageHeight;
    dicomInfo.TotalSlices= numSlices;
    dicomInfo.SliceNumber= sliceIndex;
    dicomInfo.BitDepth = 16;
    dicomInfo.ColorType = 'grayscale';
    dicomInfo.SliceThickness = slicethickness; % appropriate thickness according to Slicer files
    dicomInfo.PixelSpacing = [0.9375; 0.9375]; % Set the appropriate pixel spacing
    dicomInfo.StudyDate= datestr(date, 'yyyymmdd');
    dicomInfo.StudyTime= '101010';
    dicomInfo.SeriesDate = datestr(date,'yyyymmdd');
    dicomInfo.SeriesTime= '101010';
    dicomInfo.Modality= 'MR';
    dicomInfo.Manufacturer= 'Duke';
    dicomInfo.AccessionNumber= '';
    dicomInfo.StudyDescription= 'Final Experiment Deformation6';
    dicomInfo.SeriesDescription= 'Deformation6';
    dicomInfo.PatientID = '11132024';
    dicomInfo.PatientName.FamilyName = 'Deformed Phantom';
    dicomInfo.PatientName.GivenName = 'Final';
    dicomInfo.PatientBirthDate= '';
    dicomInfo.ImageOrientationPatient = [1;0;0;0;1;0];

    dicomInfo.ImagePositionPatient = [-imageHeight*1/2; -imageWidth*1/2; sliceIndex*slicethickness];
    dicomInfo.SliceLocation = dicomInfo.ImagePositionPatient(3);
    dicomInfo.InstanceNumber=sliceIndex;

    % Set the SOP Class UID
    
    dicomInfo.SOPClassUID = SOPclassUID; 
    dicomInfo.StudyInstanceUID = StudyInstanceUID;% unique ID
    dicomInfo.SeriesInstanceUID = SeriesInstanceUID;
    dicomInfo.SOPInstanceUID = [SOPclassUID, '.', num2str(randi(1000,1,1)), '.', num2str(randi(100,1,1))];

    % Specify the output file name
    outputFile = fullfile(outputFolder, sprintf('slice_%03d.dcm', sliceIndex));

    % Write the slice to a DICOM file
    dicomwrite(uint16(currentSlice), outputFile, dicomInfo, 'CreateMode', 'Create');
        %try 'Create' instead
end


% Display completion message
disp('DICOM conversion completed.');



