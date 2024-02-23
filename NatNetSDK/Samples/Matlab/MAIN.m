numFrames = 10;
csvFileName = 'run';

% %%% DO NOT EDIT %%%%%%

d = datetime("now");
str = string(d);
csvFileName = csvFileName + " " + str;

[rigidBodyX,rigidBodyY,rigidBodyZ,frameData,timeData] = ...
    ExtractOptitrackRBData_CSV(csvFileName, numFrames);