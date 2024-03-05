clear;clc

% %%%% EDITABLE %%%%%%%
numFrames = 10;
csvFileName = 'quatTest';

% %%% DO NOT EDIT %%%%%%

d   = datetime("now","Format","yyyy-MM-dd_HH.mm.a");
str = string(d);
csvFileName = csvFileName + "_" + str + ".csv";

[rigidBodyX,rigidBodyY,rigidBodyZ,frameData,timeData] = ...
    receiveOptitrackData_rev2(csvFileName, numFrames);