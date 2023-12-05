clc;clear;close all

% File to be read
filespec = 'C:\Users\Francisco\Documents\MATLAB\S-Kubed\data\test.csv';

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
