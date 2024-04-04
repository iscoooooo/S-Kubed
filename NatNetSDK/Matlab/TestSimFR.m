
%% Connecting to Hexapod thru MATLAB Driver

isWindows   = any (strcmp (mexext, {'mexw32', 'mexw64'}));

if (isWindows)
    matlabDriverPath = getenv ('PI_MATLAB_DRIVER');
    if (~exist(matlabDriverPath,'dir'))
        error('The PI MATLAB Driver GCS2 was not found on your system. Probably it is not installed. Please run PISoftwareSuite.exe to install the driver.');
    else
        addpath(matlabDriverPath);
    end
else
    if (~exist('/usr/local/PI/pi_matlab_driver_gcs2','dir'))
        error('The PI MATLAB Driver GCS2 was not found on your system. If you need the MATLAB driver for Linux please contact the service.');
    else
        addpath ('/usr/local/PI/pi_matlab_driver_gcs2');
    end
end

if(~exist('Controller','var'))
    Controller = PI_GCS_Controller();
    Check = true;
end
if(~isa(Controller,'PI_GCS_Controller'))
    Controller = PI_GCS_Controller();
end

if Check == true
    devicesTcpIp = Controller.EnumerateTCPIPDevices();
    disp(devicesTcpIp) 
    stageType = 'C-887.52';
    use_TCPIP_Connection = true;
    port = 50000;
    ip = '169.254.7.214';
    C887 = Controller.ConnectTCPIP(ip, port);
    C887.qIDN()
    C887 = C887.InitializeController();
end

disp('Controller Connected')

%% Hexapod Movement Function

% C887 passes the controller from the workspace to the function.
% -- 'simulationBool' shows a quick simulation of the hexapod with fluid
% movements.
% -- 'iterations' is the amount of iterations for the simulation.
% -- 'centerBool' centers the hexapod if need be.
% -- 'movement' allows the user to enter desired axes of movement:
% ---- Up to 3 axes of movement
% ---- Displays maximum movement in desired axes, positive and negative.
% ---- Executes movement, then returns to 0 position 5 seconds after.


hexsim(C887, true, 1, false, true)


function hexsim(C887, simulationBool, iterations, centerBool, movement)

    % Total Data Points
    totalDataPoints = 1000; %%%%%% Correct this

    % Preallocating Vectors
    rollData = NaN(1, totalDataPoints);
    pitchData = NaN(1, totalDataPoints);
    yawData = NaN(1, totalDataPoints);
    xData = NaN(1, totalDataPoints);
    yData = NaN(1, totalDataPoints);
    zData = NaN(1, totalDataPoints);
    B0 = NaN(1, totalDataPoints);
    B1 = NaN(1, totalDataPoints);
    B2 = NaN(1, totalDataPoints);
    B3 = NaN(1, totalDataPoints);

    % Pre-setting data index for plotting
    dataIndex = 1;

    % Figures (rotational and translational)
    figure;

    subplot(3,1,1);
    hold on
    eulerPlotRoll = plot(NaN, NaN, '-');
    eulerPlotPitch = plot(NaN, NaN, '-');
    eulerPlotYaw = plot(NaN, NaN, '-');
    title('Euler Angles')
    xlabel('Time (sec)')
    ylabel('Degrees')
    legend('Roll', 'Pitch', 'Yaw')

    subplot(3,1,2);
    hold on;
    xPlot = plot(NaN, NaN, '-');
    yPlot = plot(NaN, NaN, '-');
    zPlot = plot(NaN, NaN, '-');
    title('Position')
    xlabel('Time (sec)')
    ylabel('Position (mm)')
    legend('X', 'Y', 'Z')

    subplot(3,1,3);
    hold on
    B0plot = plot(NaN, NaN, '-');
    B1plot = plot(NaN, NaN, '-');
    B2plot = plot(NaN, NaN, '-');
    B3plot = plot(NaN, NaN, '-');
    title('Quaternions')
    xlabel('Time (sec)')
    ylabel('B-Components')
    legend('B0', 'B1', 'B2', 'B3')
    
    % Defining Time
    tic;
    time = [];

    % Defining Axes
    x = 'X'; y = 'Y'; z = 'Z';
    u = 'U'; v = 'V'; w = 'W';

    % Moving Hexapod to Center Position
    if centerBool == true
        C887.FRF(x);
        pause(10);
    end

    % Simulation
    if simulationBool == true
        N = 30;                         % Number of points
        angleR = 13;                    % Angular Radius (< 14(max))
        transR = 35;                    % Translational Radius (< 42(max))
        randR = 20;
        theta = linspace(0, 2*pi, N);
        xvalAngle = angleR*cos(theta); yvalAngle = angleR*sin(theta);
        xvalTrans = transR*cos(theta); yvalTrans = transR*sin(theta);
        xvalRandR = randR*cos(theta); yvalRandR = randR*sin(theta);

        for i = 1:iterations
            disp('Rotational Motion (U and V axes)')
            for i = 1:iterations*5
                for i = 1:length(xvalAngle)
                    C887.MOV(u, xvalAngle(i));
                    C887.MOV(v, yvalAngle(i));
                    currentTime = toc;
                    time = [time, currentTime];
                    [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                        plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                        zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                        B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
                end
            end
            pause(1)
            C887.MOV(u, 0);
            C887.MOV(v, 0);
            pause(1);
            disp('Translational Motion (X and Y axes)')
            for i = 1:iterations*5
                for i = 1:length(xvalTrans)
                    C887.MOV(x, xvalTrans(i));
                    C887.MOV(y, yvalTrans(i));
                    currentTime = toc;
                    time = [time, currentTime];
                    [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                        plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                        zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                        B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
                end
            end
            pause(1)
            C887.MOV(x, 0);
            C887.MOV(y, 0);
            pause(1)
            disp('Translation and Rotational (Z and W axes)')
            for i = 1:iterations*5
                for i = 1:length(xvalRandR)
                    C887.MOV(x, xvalRandR(i));
                    C887.MOV(y, yvalRandR(i));
                    currentTime = toc;
                    time = [time, currentTime];
                    [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                        plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                        zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                        B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
                end
            end
            pause(1)
            C887.MOV(x, 0);
            C887.MOV(y, 0);
            pause(1)
        end
    end
    cond = true;
while cond
    if movement == true
        axes = sort(input('Enter Axes of Movement (All uppercase, no spaces): ', 's'));
        if length(axes) < 4
            maxAxes = maximumMovements(axes);
        end
        message = sprintf('Maximum movement in any axis is %d\n', maxAxes);
        disp(message)
        for i = 1:length(axes)
            prompt = sprintf('Enter movement(mm) for %s-axis: ', axes(i));
            while true
                axisInput = input(prompt);
                if axisInput >= -maxAxes && axisInput <= maxAxes
                    movements(i) = axisInput;
                    break;
                else
                    disp('Invalid: Out of Range. Retry!')
                end
            end
        end
        for i = 1:length(axes)
            messageOverview = [axes(i), ': ', num2str(movements(i)), ' mm'];
            disp(messageOverview)
        end
        if length(axes) == 4
            C887.MOV(axes(1), movements(1));
            C887.MOV(axes(2), movements(2));
            C887.MOV(axes(3), movements(3));
            C887.MOV(axes(4), movements(4));
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
        elseif length(axes) == 3
            C887.MOV(axes(1), movements(1));
            C887.MOV(axes(2), movements(2));
            C887.MOV(axes(3), movements(3));
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
        elseif length(axes) == 2
            C887.MOV(axes(1), movements(1));
            C887.MOV(axes(2), movements(2));
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
        elseif length(axes) == 1
            C887.MOV(axes(1), movements(1));
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
        end
        pause(5)
        if length(axes) == 4
            C887.MOV(axes(1), 0);
            C887.MOV(axes(2), 0);
            C887.MOV(axes(3), 0);
            C887.MOV(axes(4), 0);
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
        elseif length(axes) == 3
            C887.MOV(axes(1), 0);
            C887.MOV(axes(2), 0);
            C887.MOV(axes(3), 0);
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
        elseif length(axes) == 2
            C887.MOV(axes(1), 0);
            C887.MOV(axes(2), 0);
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
        elseif length(axes) == 1
            C887.MOV(axes(1), 0);
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
                plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
                zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
                B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3);
        end
        pause(3)
    else
        cond=false;
    end
end
    
    function max = maximumMovements(axes)
    % 3 Axes of Movement describe maximum millimeters of movement in any
    % axis direction. Ex. 'XYZ': Output: 20 mm (20 mm x, 20 mm y, 20 mm z)
    if length(axes) == 5
        axesToMaxMap = containers.Map({'UVWXY', 'UVWXZ', 'UVWYZ', 'UVXYZ',...
            'UWXYZ', 'VWXYZ'}, ...
            [1, 1, 1, 1, 1, 1]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end

    if length(axes) == 4
        axesToMaxMap = containers.Map( {'UVWX', 'UVWY', 'UVWZ', 'UVXY', 'UVXZ',...
            'UVYZ', 'UWXY', 'UWXZ', 'UWYZ', 'VWXY', 'VWXZ', 'VWYZ', 'UXYZ', 'VXYZ',...
            'WXYZ'},...
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...
            1, 1, 1, 1, 1]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end

    if length(axes) == 3
        axesToMaxMap = containers.Map( {'UVW', 'UVX', 'UVY', 'UVZ', 'UWX',...
            'UWY', 'UWZ', 'UXY', 'UXZ', 'UYZ', 'VWX', 'VWY', 'VWZ', 'VXY',...
            'VXZ', 'VYZ', 'WXY', 'WXZ', 'WYZ', 'XYZ'},...
            [8, 8, 9, 7, 14, 10, 7, 14, 9, 9, ...
            10, 12, 7, 13, 9, 7, 18, 11, 12, 17]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end

    if length(axes) == 2
        axesToMaxMap = containers.Map({'XY', 'XZ', 'UX', 'VX', 'WX',...
            'YZ', 'UY', 'VY', 'WY', 'UZ', 'VZ', 'WZ', 'UV', 'UW', 'VW'},...
            [40, 18, 12, 14, 21, 18, 14, 12, 13, 9, 9, 15, 10, 12, 11]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end

    if length(axes) == 1
        axesToMaxMap = containers.Map({'X', 'Y', 'Z', 'U', 'V', 'W'}, ...
            [50, 50, 25, 14, 14, 25]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end
    end
end

function    [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B0, B1, B2, B3] = ...
    plotting(C887, eulerPlotRoll, eulerPlotPitch, eulerPlotYaw, xPlot, yPlot,...
    zPlot, time, rollData, pitchData, yawData, xData, yData, zData, dataIndex,...
    B0plot, B1plot, B2plot, B3plot, B0, B1, B2, B3)

    roll = C887.qPOS('U');
    pitch = C887.qPOS('V');
    yaw = C887.qPOS('W');
    xVal = C887.qPOS('X');
    yVal = C887.qPOS('Y');
    zVal = C887.qPOS('Z');
    B = Euler2Quat(yaw, pitch, roll);
    B0val = B(1);
    B1val = B(2);
    B2val = B(3);
    B3val = B(4);
    
    rollData(dataIndex) = roll;
    pitchData(dataIndex) = pitch;
    yawData(dataIndex) = yaw;
    xData(dataIndex) = xVal;
    yData(dataIndex) = yVal;
    zData(dataIndex) = zVal;
    B0(dataIndex) = B0val;
    B1(dataIndex) = B1val;
    B2(dataIndex) = B2val;
    B3(dataIndex) = B3val;
    
    set(eulerPlotRoll, 'XData', time(1:dataIndex), 'YData',...
        rollData(1:dataIndex));
    set(eulerPlotPitch, 'XData', time(1:dataIndex), 'YData',...
        pitchData(1:dataIndex));
    set(eulerPlotYaw, 'XData', time(1:dataIndex), 'YData',...
        yawData(1:dataIndex));
    set(xPlot, 'XData', time(1:dataIndex), 'YData',...
        xData(1:dataIndex));
    set(yPlot, 'XData', time(1:dataIndex), 'YData',...
        yData(1:dataIndex));
    set(zPlot, 'XData', time(1:dataIndex), 'YData',...
        zData(1:dataIndex));
    set(B0plot, 'XData', time(1:dataIndex), 'YData',...
        B0(1:dataIndex));
    set(B1plot, 'XData', time(1:dataIndex), 'YData',...
        B1(1:dataIndex));
    set(B2plot, 'XData', time(1:dataIndex), 'YData',...
        B2(1:dataIndex));
    set(B3plot, 'XData', time(1:dataIndex), 'YData',...
        B3(1:dataIndex));

    dataIndex = dataIndex + 1;
    drawnow;
end

function [B] = Euler2Quat(yaw, pitch, roll)
    function R1 = rotation01(angle)
        R1 = [1,0,0 ; 0,cosd(angle),sind(angle) ; 0,-sind(angle),cosd(angle)];
    end
    function R2 = rotation02(angle)
        R2 = [cosd(angle),0,-sind(angle) ; 0,1,0 ; sind(angle),0,cosd(angle)];
    end
    function R3 = rotation03(angle)
        R3 = [cosd(angle),sind(angle),0 ; -sind(angle),cosd(angle),0 ; 0,0,1];
    end
    matrix1 = rotation01(yaw);
    matrix2 = rotation02(pitch);
    matrix3 = rotation03(roll);
    R = matrix1 * matrix2 * matrix3;

    B = [0,0,0,0];
    Btest = [0,0,0,0];
    Btest(1) = sqrt(0.25*(1 + R(1,1) + R(2,2) + R(3,3)));
    Btest(2) = sqrt(0.25*(1 + R(1,1) - R(2,2) - R(3,3)));
    Btest(3) = sqrt(0.25*(1 + R(2,2) - R(1,1) - R(3,3)));
    Btest(4) = sqrt(0.25*(1 + R(3,3) - R(1,1) - R(2,2)));

    maxB = max(Btest);

    if Btest(1) == maxB % B0 = max
        B(1) = maxB;                            % B0
        B(2) = (R(2,3) - R(3,2)) / (4*B(1));    % B1
        B(3) = (R(2,1) + R(1,2)) / (4*B(2));    % B2
        B(4) = (R(1,2) - R(2,1)) / (4*B(1));    % B3
    elseif Btest(2) == maxB % B1 = max
        B(2) = maxB;                            % B1
        B(1) = (R(2,3) - R(3,2)) / (4*B(2));    % B0
        B(3) = (R(3,1) - R(1,3)) / (4*B(1));    % B2
        B(4) = (R(1,2) - R(2,1)) / (4*B(1));    % B3
    elseif Btest(3) == maxB % B2 = max
        B(3) = maxB;                            % B2
        B(1) = (R(3,1) - R(1,3)) / (4*B(3));    % B0
        B(2) = (R(2,3) - R(3,2)) / (4*B(1));    % B1
        B(4) = (R(1,2) - R(2,1)) / (4*B(1));    % B3
    elseif Btest(4) == maxB % B3 = max
        B(4) = maxB;                            % B3
        B(1) = (R(1,2) - R(2,1)) / (4*B(4));    % B0
        B(2) = (R(2,3) - R(3,2)) / (4*B(1));    % B1
        B(3) = (R(3,1) - R(1,3)) / (4*B(1));    % B2
    end
end

