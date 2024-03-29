clear;clc;close all

% %%%% EDITABLE %%%%%%%
numFrames = 200;
csvFileName = 'eulerTest';

% %%% DO NOT EDIT %%%%%%

% Define the directory to save data in
relativeDirectory = "out";

% Define the filename
d   = datetime("now","Format","yyyy-MM-dd_HH.mm.a");
str = string(d);
csvFileName = csvFileName + "_" + str + ".csv";

% Full path using relative path
fullFileName = fullfile(relativeDirectory,csvFileName);

% Begin polling and saving data
[rigidBodyX,rigidBodyY,rigidBodyZ,frameData,timeData] = ...
    receiveOptitrackData_rev3(fullFileName, numFrames);