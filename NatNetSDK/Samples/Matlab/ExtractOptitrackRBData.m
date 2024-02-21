% Optitrack Matlab / NatNet Polling Sample
% ...

function [rigidBodyX,rigidBodyY,rigidBodyZ,frameData,timeData] = ExtractOptitrackRBData()

    fprintf('NatNet Polling Sample Start\n')

    % create an instance of the natnet client class
    fprintf('Creating natnet class object\n')
    natnetclient = natnet();

    % connect the client to the server (multicast over local loopback) -
    % modify for your network
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
    numFrames = 10; % Set the number of frames you want to capture
    frameData = zeros(1, numFrames);
    timeData = zeros(1, numFrames);
    rigidBodyNames = cell(1, model.RigidBodyCount);
    rigidBodyX = zeros(model.RigidBodyCount, numFrames);
    rigidBodyY = zeros(model.RigidBodyCount, numFrames);
    rigidBodyZ = zeros(model.RigidBodyCount, numFrames);

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
            rigidBodyX(i, idx) = data.RigidBodies(i).x * 1000;
            rigidBodyY(i, idx) = data.RigidBodies(i).y * 1000;
            rigidBodyZ(i, idx) = data.RigidBodies(i).z * 1000;

            fprintf('Name:"%s"  ', rigidBodyNames{i})
            fprintf('X:%0.1fmm  ', rigidBodyX(i, idx))
            fprintf('Y:%0.1fmm  ', rigidBodyY(i, idx))
            fprintf('Z:%0.1fmm\n', rigidBodyZ(i, idx))
        end
    end

    disp('NatNet Polling Sample End')

    % Now, you can use the stored data in frameData, timeData, rigidBodyNames, rigidBodyX, rigidBodyY, rigidBodyZ arrays for analysis.
end

