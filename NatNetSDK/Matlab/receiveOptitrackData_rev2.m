% -----------------------MATLAB Script Information----------------------
%{
Written by: Simulink Team
Date: 2/10/23

PURPOSE
This function stores frame, time, and  rigid body data streamed from motive 
using the natnet wrapper class and also outputs the data to a CSV file.

REFERENCES
Solving Sets of Linear Algebraic Equations (notes), P. Nissenson

INPUTS
- numFrames   : Number of frame desired for capture 
- csvFileName : Name of the CSV file to output

OUTPUTS
- rigidbodyX  : X coords
- rigidBodyY  : Y coords
- rigidBodyZ  : Z coords
- rigidbodyqX :
- rigidBodyqY :
- rigidBodyqZ :
- rigidBodyqW :
- frameData   :
- timeData    :

OTHER
.m files required              : natnet.m
Files required (not .m)        : none
User-defined functions         : saveToCSV (nested)
%}

function [rigidBodyX,rigidBodyY,rigidBodyZ,frameData,timeData] = ...
    receiveOptitrackData_rev2(csvFileName, numFrames)

fprintf('NatNet Polling Sample Start\n')

% create an instance of the natnet client class
fprintf('Creating natnet class object\n')
natnetclient = natnet();

% connect the client to the server (multicast over local loopback) - modify for your network
fprintf('Connecting to the server\n')
natnetclient.HostIP = '127.0.0.1';
natnetclient.ClientIP = '127.0.0.1';
natnetclient.ConnectionType = 'Multicast';
natnetclient.connect;
if (natnetclient.IsConnected == 0)
    fprintf('Client failed to connect\n')
    fprintf('\tMake sure the host is connected to the network\n')
    fprintf('\tand that the host and client IP addresses are correct\n\n')
    return
end

% get the asset descriptions for the asset names
model = natnetclient.getModelDescription;
if (model.RigidBodyCount < 1)
    return
end

% Initialize arrays to store data
frameData = zeros(1, numFrames);
timeData = zeros(1, numFrames);
rigidBodyNames = cell(1, model.RigidBodyCount);
rigidBodyX  = zeros(numFrames, model.RigidBodyCount);
rigidBodyY  = zeros(numFrames, model.RigidBodyCount);
rigidBodyZ  = zeros(numFrames, model.RigidBodyCount);
rigidBodyRoll = zeros(numFrames, model.RigidBodyCount);
rigidBodyPitch = zeros(numFrames, model.RigidBodyCount);
rigidBodyYaw = zeros(numFrames, model.RigidBodyCount);

% Poll for the rigid body data at regular intervals (~1 sec) for 10 sec.
fprintf('\nStoring rigid body frame data into arrays...\n\n')
for idx = 1:numFrames
    java.lang.Thread.sleep(996);
    data = natnetclient.getFrame; % method to get current frame

    if (isempty(data.RigidBodies(1)))
        fprintf('\tPacket is empty/stale\n')
        fprintf('\tMake sure the server is in Live mode or playing in playback\n\n')
        return
    end

    frameData(idx) = data.iFrame;
    timeData(idx) = data.fTimestamp;

    fprintf('Frame:%6d  ', frameData(idx))
    fprintf('Time:%0.2f\n', timeData(idx))

    for i = 1:model.RigidBodyCount
        rigidBodyNames{i} = model.RigidBody(i).Name;
        % Positions
        rigidBodyX(idx, i) = data.RigidBodies(i).x * 1000;
        rigidBodyY(idx, i) = data.RigidBodies(i).y * 1000;
        rigidBodyZ(idx, i) = data.RigidBodies(i).z * 1000;
        % Quaternions
        q = quaternion(data.RigidBodies(i).qw, data.RigidBodies(i).qx, ...
            data.RigidBodies(i).qy, data.RigidBodies(i).qz);
        % Convert quaternion to Euler angles using 3-2-1 sequence
        eulerAngles = q.EulerAngles('ZYX');
        % Extract Euler angles
        rigidBodyRoll(idx, i) = eulerAngles(1);
        rigidBodyPitch(idx, i) = eulerAngles(2);
        rigidBodyYaw(idx, i) = eulerAngles(3);

        % Command Window Output
        fprintf('Name:"%s"  ', rigidBodyNames{i})
        fprintf('X:%0.1fmm  ', rigidBodyX(idx, i))
        fprintf('Y:%0.1fmm  ', rigidBodyY(idx, i))
        fprintf('Z:%0.1fmm\n', rigidBodyZ(idx, i))
        fprintf('           ')
        fprintf('       Roll:%0.1f   ', rigidBodyRoll(idx, i))
        fprintf('Pitch:%0.1f   ', rigidBodyPitch(idx, i))
        fprintf('Yaw:%0.1f   \n', rigidBodyYaw(idx, i))
    end
end

disp('NatNet Polling Sample End')

% Initialize arrays to store Euler angles and time data
eulerAnglesData = zeros(numFrames, 3, model.RigidBodyCount);
timeDataArray = zeros(numFrames, model.RigidBodyCount);

% Plot Euler angles vs time for each rigid body
for i = 1:model.RigidBodyCount
    figure;
    plot(timeDataArray(:, i), eulerAnglesData(:, :, i));
    xlabel('Time');
    ylabel('Euler Angles');
    title(['Euler Angles vs Time for Rigid Body ', num2str(i)]);
    legend('Roll', 'Pitch', 'Yaw', 'Location', 'best');
    grid on;
end

% Save data to CSV file
saveToCSV(csvFileName, frameData, timeData, rigidBodyNames, ...
    rigidBodyX, rigidBodyY, rigidBodyZ, ...
    rigidBodyRoll,rigidBodyPitch,rigidBodyYaw);
end

function saveToCSV(csvFileName,frameData, timeData, rigidBodyNames, ...
    rigidBodyX, rigidBodyY, rigidBodyZ, ...
    rigidBodyRoll,rigidBodyPitch,rigidBodyYaw)
% Combine data into a table
%   Need to solve frame & time data inconsistency
dataTable = table(frameData', timeData', 'VariableNames', {'Frame', 'Time'});

for i = 1:numel(rigidBodyNames)
    dataTable.('rigidBody_X') = rigidBodyX(:, i);
    dataTable.('rigidBody_Y') = rigidBodyY(:, i);
    dataTable.('rigidBody_Z') = rigidBodyZ(:, i);
    dataTable.('rigidBody_Roll') = rigidBodyRoll(:, i);
    dataTable.('rigidBody_Pitch') = rigidBodyPitch(:, i);
    dataTable.('rigidBody_Yaw') = rigidBodyYaw(:, i);
end

% Write data to CSV file
writetable(dataTable, csvFileName,'WriteVariableNames',true);
fprintf('Data saved to %s\n', csvFileName);
end