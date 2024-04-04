% -----------------------MATLAB Script Information----------------------
%{
Written by: Simulink Team
Date: 2/10/23

PURPOSE
This function stores frame, time, and  rigid body data streamed from motive 
using the natnet wrapper class and also outputs the data to a CSV file.

REFERENCES
Optitrack Documentation

INPUTS
- numFrames   : Number of frame desired for capture 
- csvFileName : Name of the CSV file to output

OUTPUTS
- rigidbodyX     : X coords
- rigidBodyY     : Y coords
- rigidBodyZ     : Z coords
- rigidbodyRoll  : Roll angles
- rigidBodyPitch : Pitch angles
- rigidBodyYaw   : Yaw angles 
- frameData      : Frame vector
- timeData       : Time vector

OTHER
.m files required              : natnet.m
Files required (not .m)        : saveToCSV.m
User-defined functions         : none
%}

function [rigidBodyX,rigidBodyY,rigidBodyZ,frameData,timeData] = ...
    receiveOptitrackData_rev3(csvFileName, numFrames)

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

% % Vertical offset (also need to include distance to vertical distance to
% % geometric center of rigid body)
% offset = -327.45; % [mm]

% Define the rotation matrix for a 90-degree rotation about the x-axis 
Rx = [1,      0          0    ;
      0   cosd(90)  -sind(90) ;
      0   sind(90)   cosd(90)];

% Plotting setup
figure('WindowStyle', 'docked'); % 'docked' to dock the figure
subplot(2, 1, 1);
hold on;
posPlotX = plot(nan, nan, 'r-');
posPlotY = plot(nan, nan, 'g-');
posPlotZ = plot(nan, nan, 'b-');
title('Real-time Position Data');
xlabel('Frame');
ylabel('Position (mm)');
legend('X', 'Y', 'Z');
grid on;
hold off;

subplot(2, 1, 2);
hold on;
anglePlotRoll = plot(nan, nan, 'r-');
anglePlotPitch = plot(nan, nan, 'g-');
anglePlotYaw = plot(nan, nan, 'b-');
title('Real-time Euler Angles');
xlabel('Frame');
ylabel('Angle (degrees)');
legend('Roll', 'Pitch', 'Yaw');
grid on;
hold off;

% Poll for the rigid body data at regular intervals (~1 sec) for 10 sec.
fprintf('\nStoring rigid body frame data into arrays...\n\n')
for idx = 1:numFrames
    java.lang.Thread.sleep(50);
    data = natnetclient.getFrame; % method to get current frame

    if (isempty(data.RigidBodies(1)))
        fprintf('\tPacket is empty/stale\n')
        fprintf('\tMake sure the server is in Live mode or playing in playback\n\n')
        return
    end

    frameData(idx) = idx;
    timeData(idx) = data.fTimestamp - timeData(1);

    fprintf('Frame:%6d  ', frameData(idx))
    fprintf('Time:%0.2f\n', timeData(idx))

    for i = 1:model.RigidBodyCount
        
        rigidBodyNames{i} = model.RigidBody(i).Name;

        % Positions
        rigidBodyXYZ = Rx*[data.RigidBodies(i).x; data.RigidBodies(i).y;
            data.RigidBodies(i).z];
        rigidBodyX(idx, i) = rigidBodyXYZ(1) * 1000;
        rigidBodyY(idx, i) = rigidBodyXYZ(2) * 1000;
        rigidBodyZ(idx, i) = rigidBodyXYZ(3) * 1000;

        % Quaternions
        q = quaternion(data.RigidBodies(i).qw, data.RigidBodies(i).qx, ...
            data.RigidBodies(i).qy, data.RigidBodies(i).qz);
        qRot = quaternion( 0, 0, 0, 1);
        q = mtimes( q, qRot);

        % Convert quaternion to Euler angles using 3-2-1 sequence
        eulerAngles = q.EulerAngles('ZYX');

        % Extract Euler angles
        rigidBodyRoll(idx, i) = eulerAngles(1)* -180/pi;
        rigidBodyPitch(idx, i) = eulerAngles(2)* 180/pi;
        rigidBodyYaw(idx, i) = eulerAngles(3)* -180/pi;

        % Command Window Output
        fprintf('Name:"%s"  ', rigidBodyNames{i})
        fprintf('X:%0.1fmm  ', rigidBodyX(idx, i))
        fprintf('Y:%0.1fmm  ', rigidBodyY(idx, i))
        fprintf('Z:%0.1fmm\n', rigidBodyZ(idx, i))
        fprintf('           ')
        fprintf('       Roll:%0.1f   ', rigidBodyRoll(idx, i))
        fprintf('Pitch:%0.1f   ', rigidBodyPitch(idx, i))
        fprintf('Yaw:%0.1f   \n', rigidBodyYaw(idx, i))

        % Update plots
        set(posPlotX, 'XData', 1:numFrames, 'YData', rigidBodyX(:,1)');
        set(posPlotY, 'XData', 1:numFrames, 'YData', rigidBodyY(:,1)');
        set(posPlotZ, 'XData', 1:numFrames, 'YData', rigidBodyZ(:,1)');
        set(anglePlotRoll, 'XData', 1:numFrames, 'YData', rigidBodyRoll(:,1)');
        set(anglePlotPitch, 'XData', 1:numFrames, 'YData', rigidBodyPitch(:,1)');
        set(anglePlotYaw, 'XData', 1:numFrames, 'YData', rigidBodyYaw(:,1)');
        
        % Dynamically move the axis of the graph
        subplot(2,1,1)
        axis( [ -50 + frameData(idx) , 20 + frameData(idx) , -500 , 500 ] );

        subplot(2,1,2)
    	axis( [ -50 + frameData(idx) , 20 + frameData(idx) , -180 , 180 ] );
        drawnow;
    end
end

timeData(1) = 0;

disp('NatNet Polling Sample End')

% % Initialize arrays to store Euler angles and time data
% eulerAnglesData = zeros(numFrames, 3, model.RigidBodyCount);
% timeDataArray = zeros(numFrames, model.RigidBodyCount);

% % Plot Euler angles vs time for each rigid body
% for i = 1:model.RigidBodyCount
%     figure;
%     plot(timeDataArray(:, i), eulerAnglesData(:, :, i));
%     xlabel('Time');
%     ylabel('Euler Angles');
%     title(['Euler Angles vs Time for Rigid Body ', num2str(i)]);
%     legend('Roll', 'Pitch', 'Yaw', 'Location', 'best');
%     grid on;
% end

% Save data to CSV file
saveToCSV(csvFileName, frameData, timeData, rigidBodyNames, ...
    rigidBodyX, rigidBodyY, rigidBodyZ, ...
    rigidBodyRoll,rigidBodyPitch,rigidBodyYaw);
end
