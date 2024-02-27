clear;clc

% %%%% EDITABLE %%%%%%%
numFrames = 10;
csvFileName = 'quatTest';

% %%% DO NOT EDIT %%%%%%

d   = datetime("now","Format","yyy-MM-dd_HH.mm.a");
str = string(d);
csvFileName = csvFileName + "_" + str + ".csv";

[rigidBodyX,rigidBodyY,rigidBodyZ,frameData,timeData] = ...
    ExtractOptitrackRBData_CSV(csvFileName, numFrames);