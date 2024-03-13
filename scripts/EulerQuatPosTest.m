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
