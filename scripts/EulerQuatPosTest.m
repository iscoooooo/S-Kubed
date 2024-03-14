<<<<<<< HEAD
% Defines movement
N = 30;                         % Number of points
angleR = 13;                    % Angular Radius (< 14(max))
transR = 35;                    % Translational Radius (< 42(max))
randR = 20;
theta = linspace(0, 2*pi, N);
xvalAngle = angleR*cos(theta); yvalAngle = angleR*sin(theta);
xvalTrans = transR*cos(theta); yvalTrans = transR*sin(theta);
xvalRandR = randR*cos(theta); yvalRandR = randR*sin(theta);
iterations = 1;

% Defining Axes
x = 'X'; y = 'Y'; z = 'Z';
u = 'U'; v = 'V'; w = 'W';

% Total Data Points
totalDataPoints = iterations * N * 2*2*2; %%%%%% Correct this

% Preallocating Vectors
rollData = NaN(1, totalDataPoints);
pitchData = NaN(1, totalDataPoints);
yawData = NaN(1, totalDataPoints);
xData = NaN(1, totalDataPoints);
yData = NaN(1, totalDataPoints);
zData = NaN(1, totalDataPoints);

% Time Vector for X-Axis
dataIndex = 1;
dt = 0.05;
time = (0:dt:(totalDataPoints - 1)*dt);

% Figures (rotational and translational)
figure;

subplot(2,1,1);
hold on
eulerPlotRoll = plot(NaN, NaN, '-');
eulerPlotPitch = plot(NaN, NaN, '-');
eulerPlotYaw = plot(NaN, NaN, '-');
title('Euler Angles')
xlabel('Time (sec)')
ylabel('Degrees')
legend('Roll', 'Pitch', 'Yaw')

subplot(2,1,2);
hold on;
xPlot = plot(NaN, NaN, '-');
yPlot = plot(NaN, NaN, '-');
zPlot = plot(NaN, NaN, '-');
title('Position')
xlabel('Time (sec)')
ylabel('Position (mm)')
legend('X', 'Y', 'Z')

for j = 1:iterations
    for k = 1:iterations*2
        for i = 1:length(xvalAngle)
            C887.MOV(u, xvalAngle(i));
            C887.MOV(v, yvalAngle(i));
            roll = C887.qPOS('U');
            pitch = C887.qPOS('V');
            yaw = C887.qPOS('W');
            xVal = C887.qPOS('X');
            yVal = C887.qPOS('Y');
            zVal = C887.qPOS('Z');
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex] = ...
                plotting(roll, pitch, yaw, xVal, yVal, zVal, eulerPlotRoll, ...
                eulerPlotPitch, eulerPlotYaw, xPlot, yPlot, zPlot, time, ...
                rollData, pitchData, yawData, xData, yData, zData, dataIndex);
            pause(0.1)
        end
    end
    pause(2)
    C887.MOV(u, 0)
    C887.MOV(v, 0)
    pause(2)
    for k = 1:iterations*2
        for i = 1:length(xvalTrans)
            C887.MOV(x, xvalTrans(i));
            C887.MOV(y, yvalTrans(i));
            roll = C887.qPOS('U');
            pitch = C887.qPOS('V');
            yaw = C887.qPOS('W');
            xVal = C887.qPOS('X');
            yVal = C887.qPOS('Y');
            zVal = C887.qPOS('Z');
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex] = ...
                plotting(roll, pitch, yaw, xVal, yVal, zVal, eulerPlotRoll, ...
                eulerPlotPitch, eulerPlotYaw, xPlot, yPlot, zPlot, time, ...
                rollData, pitchData, yawData, xData, yData, zData, dataIndex);
            pause(0.1)
        end
    end
    pause(2)
    C887.MOV(x, 0);
    C887.MOV(y, 0);
    pause(2)
    for k = 1:iterations*2
        for i = 1:length(xvalRandR)
            C887.MOV(z, xvalRandR(i));
            C887.MOV(w, yvalRandR(i));
            roll = C887.qPOS('U');
            pitch = C887.qPOS('V');
            yaw = C887.qPOS('W');
            xVal = C887.qPOS('X');
            yVal = C887.qPOS('Y');
            zVal = C887.qPOS('Z');
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex] = ...
                plotting(roll, pitch, yaw, xVal, yVal, zVal, eulerPlotRoll, ...
                eulerPlotPitch, eulerPlotYaw, xPlot, yPlot, zPlot, time, ...
                rollData, pitchData, yawData, xData, yData, zData, dataIndex);
            pause(0.1)
        end
    end
    pause(1)
    C887.MOV(z, 0);
    C887.MOV(w, 0);
    pause(1)
   
end

function [rollData, pitchData, yawData, xData, yData, zData, dataIndex] = ...
    plotting(roll, pitch, yaw, xVal, yVal, zVal, eulerPlotRoll,...
    eulerPlotPitch, eulerPlotYaw, xPlot, yPlot, zPlot, time, rollData,...
    pitchData, yawData, xData, yData, zData, dataIndex)

    rollData(dataIndex) = roll;
    pitchData(dataIndex) = pitch;
    yawData(dataIndex) = yaw;
    xData(dataIndex) = xVal;
    yData(dataIndex) = yVal;
    zData(dataIndex) = zVal;
    
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

    dataIndex = dataIndex + 1;
    drawnow;
end
=======
% Defines movement
N = 30;                         % Number of points
angleR = 13;                    % Angular Radius (< 14(max))
transR = 35;                    % Translational Radius (< 42(max))
randR = 20;
theta = linspace(0, 2*pi, N);
xvalAngle = angleR*cos(theta); yvalAngle = angleR*sin(theta);
xvalTrans = transR*cos(theta); yvalTrans = transR*sin(theta);
xvalRandR = randR*cos(theta); yvalRandR = randR*sin(theta);
iterations = 1;
multiplier = 5;

% Defining Axes
x = 'X'; y = 'Y'; z = 'Z';
u = 'U'; v = 'V'; w = 'W';

% Total Data Points
totalDataPoints = iterations * N * multiplier*3; %%%%%% Correct this

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

tic;
time = [];

for j = 1:iterations
    for k = 1:iterations*multiplier
        for i = 1:length(xvalAngle)
            C887.MOV(u, xvalAngle(i));
            C887.MOV(v, yvalAngle(i));
            roll = C887.qPOS('U');
            pitch = C887.qPOS('V');
            yaw = C887.qPOS('W');
            xVal = C887.qPOS('X');
            yVal = C887.qPOS('Y');
            zVal = C887.qPOS('Z');
            B = Euler2Quat(yaw, pitch, roll);
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B] = ...
                plotting(roll, pitch, yaw, xVal, yVal, zVal, eulerPlotRoll, ...
                eulerPlotPitch, eulerPlotYaw, xPlot, yPlot, zPlot, time, ...
                rollData, pitchData, yawData, xData, yData, zData, dataIndex, B, time);
            pause(0.1)
        end
    end
    pause(2)
    C887.MOV(u, 0)
    C887.MOV(v, 0)
    pause(2)
    for k = 1:iterations*multiplier
        for i = 1:length(xvalTrans)
            C887.MOV(x, xvalTrans(i));
            C887.MOV(y, yvalTrans(i));
            roll = C887.qPOS('U');
            pitch = C887.qPOS('V');
            yaw = C887.qPOS('W');
            xVal = C887.qPOS('X');
            yVal = C887.qPOS('Y');
            zVal = C887.qPOS('Z');
            B = Euler2Quat(yaw, pitch, roll);
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B] = ...
                plotting(roll, pitch, yaw, xVal, yVal, zVal, eulerPlotRoll, ...
                eulerPlotPitch, eulerPlotYaw, xPlot, yPlot, zPlot, time, ...
                rollData, pitchData, yawData, xData, yData, zData, dataIndex, B, time);
            pause(0.1)
        end
    end
    pause(2)
    C887.MOV(x, 0);
    C887.MOV(y, 0);
    pause(2)
    for k = 1:iterations*multiplier
        for i = 1:length(xvalRandR)
            C887.MOV(z, xvalRandR(i));
            C887.MOV(w, yvalRandR(i));
            roll = C887.qPOS('U');
            pitch = C887.qPOS('V');
            yaw = C887.qPOS('W');
            xVal = C887.qPOS('X');
            yVal = C887.qPOS('Y');
            zVal = C887.qPOS('Z');
            B = Euler2Quat(yaw, pitch, roll);
            currentTime = toc;
            time = [time, currentTime];
            [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B] = ...
                plotting(roll, pitch, yaw, xVal, yVal, zVal, eulerPlotRoll, ...
                eulerPlotPitch, eulerPlotYaw, xPlot, yPlot, zPlot, time, ...
                rollData, pitchData, yawData, xData, yData, zData, dataIndex, B, time);
            pause(0.1)
        end
    end
    pause(1)
    C887.MOV(z, 0);
    C887.MOV(w, 0);
    pause(1)
   
end

function [rollData, pitchData, yawData, xData, yData, zData, dataIndex, B] = ...
    plotting(roll, pitch, yaw, xVal, yVal, zVal, eulerPlotRoll,...
    eulerPlotPitch, eulerPlotYaw, xPlot, yPlot, zPlot, rollData,...
    pitchData, yawData, xData, yData, zData, dataIndex, B, time)

    rollData(dataIndex) = roll;
    pitchData(dataIndex) = pitch;
    yawData(dataIndex) = yaw;
    xData(dataIndex) = xVal;
    yData(dataIndex) = yVal;
    zData(dataIndex) = zVal;
    B0(dataIndex) = B(1);
    B1(dataIndex) = B(2);
    B2(dataIndex) = B(3);
    B3(dataIndex) = B(4);
    
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
>>>>>>> 313d4e16a8a2df6e2aaed780051d210199bfa9f6
