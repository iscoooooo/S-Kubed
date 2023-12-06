% This is a test script that extracts rigid body data from a csv output 
% file from Motive and plots the cartesian coordinates over time, and 
% shows an animation of the attitude variation over time.

clc;clear;close all

%% EDIT %%
fileName = 'test.csv'; % specify file name from the data folder

%% DO NOT EDIT %%

% Get file from the data folder path
filespec = "../data/" + fileName;

% Extract quaternions and cartesian coords at each sample frame/time
[frame,time,quat,pos] = statereader(filespec);

% Figure properties
set(gcf,'units','normalized','position', [0, 0, .5, .5],...
    'DefaultTextInterpreter','Latex');
movegui(gcf,'center')

% Plot Cartesian coords
subplot(1,2,1)
plot3(pos(:,1), pos(:,2), pos(:,3))
title('Position vs. time')
xlabel('mm'), ylabel('mm'), zlabel('mm')
axis equal
grid on

% Visualize quaternions
subplot(1,2,2)
for ii = 1:length(quat)
    q = quaternion(quat(ii,1),quat(ii,2),quat(ii,3),quat(ii,4));
    fig = poseplot(q);
    title('Attitude vs. time')
    pause(1e-6)
    delete(fig)
end
