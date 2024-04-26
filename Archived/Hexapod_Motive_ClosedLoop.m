%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S-Kubed 2024
% Written by Andre Turpin & Matt Portugal
clc; close all; clearvars -except C887 Controller devicesTcpIp ip matlabDriverPath port stageType use_TCPIP_Connection
%
%
% To-Do: Change Error to a single XYZ Error instead of seperate
%
% Note: Hexapod moves an average of 0.0977mm per step
%

Rotational = 'N';
Translational = 'Y';

Plot_Time = 'Y';
Plot_Step = 'N';
Perturbation = 'User'; % 'User' or 'Random'

%%%%%%%%%%%%%%%%%%% Hexapod Initialization %%%%%%%%%%%%%%%%%%%

% Connect to Hexapod
disp('Checking connection with Hexapod...');
pause(0.5)
if exist('C887','var')
    disp('The hexapod is connected.');
else
    disp('The hexapod is not connected');
    run("Connection2Hexapod.m");
    disp('Initializing connection to Hexapod...');
    pause(2)
    disp('Hexapod is now connected');
end

% Center Hexapod
if all(C887.qPOS <= 0.2 & C887.qPOS >= -0.2)
    disp('Hexapod is at the origin')
else
    disp('Hexapod is not at the origin, Centering....')
    C887.FRF('X');

    pause(9)
end



%%%%%%%%%%%%%%%%%%% NatNet Initialization %%%%%%%%%%%%%%%%%%%

% Check if the Motive application is open

[status, cmdout] = system('tasklist /FI "IMAGENAME eq Motive.exe"');
if contains(cmdout, 'Motive.exe')
    disp('Motive is running');
else
    disp('Motive is not running');
    system('start "" "C:\Program Files\OptiTrack\Motive\Motive.exe"');
    fprintf('Opening Motive.... \n \n')
    pause(15)

end

obj = natnet();

if (obj.IsConnected == 0)
    fprintf('Connecting to the server\n')
    obj.HostIP = '127.0.0.1';
    obj.ClientIP = '127.0.0.1';
    obj.ConnectionType = 'Multicast';
    obj.connect;
    if (obj.IsConnected == 0)
        fprintf('Client failed to connect\n')
        fprintf('\tMake sure the host is connected to the network\n')
        fprintf('\tand that the host and client IP addresses are correct\n\n')
        return
    end
end

model = obj.getModelDescription;
if (model.RigidBodyCount < 1)
    return
end


%%%%%%%%%%%%%%%% User-Input Perturbation %%%%%%%%%%%%%%%%

if strcmp(Perturbation,'User') == true
    
    xDist = 0;
    yDist = 0;
    zDist = 0;
    axisCount = 0;

    fprintf('\nMax X: +/- 49 mm\n\n');
    xDist = input('Enter Movement in X-Direction: ');

    if xDist > 39 || xDist < -39
        movementArray = [xDist, 0, 0];
    elseif xDist <= 39 && xDist > 16 || xDist < -16 && xDist >= -39
        fprintf('\nMax Y: +/- 39 mm\n');
        yDist = input('Enter Movement in Y-Direction: ');
        movementArray = [xDist, yDist, 0];
    elseif xDist <= 16 || xDist <= -16
        fprintf('\nMax Y: +/- 16 mm\n');
        yDist = input('Enter Movement in Y-Direction: ');
        fprintf('\nMax Z: +/- 16 mm\n');
        zDist = input('Enter Movement in Z-Direction: ');
        movementArray = [xDist, yDist, zDist];
    end
end

%%%%%%%%%%%%%%%% Randomized Perturbation %%%%%%%%%%%%%%%%

disp('Perturbing Randomly....')
pause(2)
if strcmp(Perturbation,'Random') == true
    xDist = (rand() * 100) - 50;

    if xDist > 40 || xDist < -40
        movementArray = [xDist, 0, 0];
    elseif xDist <= 40 && xDist > 17 || xDist < -17 && xDist >= -40
        yDist = (rand() * 80) - 40;
        movementArray = [xDist, yDist, 0];
    elseif xDist <= 17 || xDist <= -17
        yDist = (rand() * 34) - 17;
        zDist = (rand() * 34) - 17;
        movementArray = [xDist, yDist, zDist];
    end
end


%%%%%%%%%%%%%%%% Establish Initial Positions as read by Motive %%%%%%%%%%%%%%%%

InitialX = (OptiTrak_Data(obj,'X'))/10;
InitialY = (OptiTrak_Data(obj,'Y'))/10;
InitialZ = (OptiTrak_Data(obj,'Z'))/10;
InitialU = (OptiTrak_Data(obj,'U'))/10;
InitialV = (OptiTrak_Data(obj,'V'))/10;
InitialW = (OptiTrak_Data(obj,'W'))/10;

%%%%%%%%%%%%%%%% Start Condition Loop %%%%%%%%%%%%%%%%

% Define the desired positions
DesiredX = movementArray(1);
DesiredY = movementArray(2);
DesiredZ = movementArray(3);
DesiredU = movementArray(1);
DesiredV = movementArray(2);
DesiredW = movementArray(3);

% Adjust desired positions for any initial offset
displacementX = DesiredX - InitialX;
displacementY = DesiredY - InitialY;
displacementZ = DesiredZ - InitialZ;
displacementU = DesiredU - InitialU;
displacementV = DesiredV - InitialV;
displacementW = DesiredW - InitialW;

% Update current position to the initial position
CurrentX = abs(InitialX);
CurrentY = abs(InitialY);
CurrentZ = abs(InitialZ);
CurrentU = abs(InitialU);
CurrentV = abs(InitialV);
CurrentW = abs(InitialW);

% Compute Error at initial position
xError = DesiredX - CurrentX;
yError = DesiredY - CurrentY;
zError = DesiredZ - CurrentZ;
uError = DesiredU - CurrentU;
vError = DesiredV - CurrentV;
wError = DesiredW - CurrentW;



fprintf('The initial error prior to movement is: \n')
fprintf('X-Error: [%0.3f]  Y-Error: [%0.3f]  Z-Error: [%0.3f]',xError,yError,zError)

% Initialize Arrays for Plots
xPositionArray = zeros();
yPositionArray = zeros();
zPositionArray = zeros();
uPositionArray = zeros();
vPositionArray = zeros();
wPositionArray = zeros();

stepArray = zeros();
timeArray = zeros();

xErrorArray = zeros();
yErrorArray = zeros();
zErrorArray = zeros();
uErrorArray = zeros();
vErrorArray = zeros();
wErrorArray = zeros();

xHexaPosArray = zeros();
yHexaPosArray = zeros();
zHexaPosArray = zeros();
uHexaPosArray = zeros();
vHexaPosArray = zeros();
wHexaPosArray = zeros();

normPosArray = zeros();
normHexArray = zeros();


% Translational -----------------------------------------------------------


% Reset iterator
n = 1;
tic;
Error = [xError, yError, zError];

while abs(Error(1)) > 0.25 && abs(Error(2)) > 0.25 && abs(Error(3)) > 0.25 ||...
    abs(Error(1)) > 0.25 && abs(Error(2)) > 0.5 && abs(Error(3)) < 0.5 ||...
    abs(Error(1)) > 0.25 && abs(Error(2)) < 0.5 && abs(Error(3)) < 0.5
    
    if xError >= 0.25
        xError = DesiredX - CurrentX;
    elseif xError <= -0.25
        xError = DesiredX + CurrentX;
    end

    if yError >= 0.25
        yError = DesiredY - CurrentY;
    elseif yError <= -0.25
        yError = DesiredY + CurrentY;
    end

    if zError >= 0.25
        zError = DesiredZ - CurrentZ;
    elseif zError <= -0.25
        zError = DesiredZ + CurrentZ;
    end

    CurrentX = OptiTrak_Data(obj, 'X');
    CurrentY = OptiTrak_Data(obj, 'Y');
    CurrentZ = OptiTrak_Data(obj, 'Z');

    xPositionArray = [xPositionArray, CurrentX];
    yPositionArray = [yPositionArray, CurrentY];
    zPositionArray = [zPositionArray, CurrentZ];

    CurrentTime = round(toc, 2);
    timeArray = [timeArray, CurrentTime];
    stepArray = [stepArray, n];

    CurrentX = round(abs(CurrentX), 2); CurrentY = round(abs(CurrentY), 2); CurrentZ = round(abs(CurrentZ), 2);
    
    HexaPosX = round(C887.qPOS('X'), 2); HexaPosY = round(C887.qPOS('Y'), 2); HexaPosZ = round(C887.qPOS('Z'), 2);
    
    DesiredX = round(DesiredX, 2); DesiredY = round(DesiredY, 2); DesiredZ = round(DesiredZ, 2);

    xError = round(xError, 2); yError = round(yError, 2); zError = round(zError, 2);
    
    tableVals = table(n', CurrentTime', xError', yError', zError', CurrentX', CurrentY', CurrentZ', HexaPosX', HexaPosY', HexaPosZ', DesiredX', DesiredY', DesiredZ');
    tableVals.Properties.VariableNames = {'Step', 'Time', 'X-Err', 'Y-Err', 'Z-Err', 'Pos-X', 'Pos-Y', 'Pos-Z', 'Hex-X', 'Hex-Y', 'Hex-Z', 'Des-X', 'Des-Y', 'Des-Z'};
    disp(tableVals)

    xErrorArray = [xErrorArray, xError];
    yErrorArray = [yErrorArray, yError];
    zErrorArray = [zErrorArray, zError];

    xHexaPosArray = [xHexaPosArray, HexaPosX];
    yHexaPosArray = [yHexaPosArray, HexaPosY];
    zHexaPosArray = [zHexaPosArray, HexaPosZ];

    normPos = norm([xError, yError, zError]);
    normHex = norm([HexaPosX, HexaPosY, HexaPosZ]);

    normPosArray = [normPosArray, normPos];
    normHexArray = [normHexArray, normHex];

    if xError >= 0.5
        C887.MOV('X', 0.1*n)
    elseif xError <= -0.5
        C887.MOV('X', -0.1*n)
    end

    if yError >= 0.5
        C887.MOV('Y', 0.1*n)
    elseif yError <= -0.5
        C887.MOV('Y', -0.1*n)
    end

    if zError >= 0.5
        C887.MOV('Z', 0.1*n)
    elseif zError <= -0.5
        C887.MOV('Z', -0.1*n)
    end
    
    n = n+1;
    if abs(xError) < 0.4 && abs(yError) < 0.4 && abs(zError) < 0.4
        break;
    end
end


% Rotational --------------------------------------------------------------


% Reset iterator
n = 1;
tic;
rotError = [uError, vError, wError];

while abs(rotError(1)) > 0.25 && abs(rotError(2)) > 0.25 && abs(rotError(3)) > 0.25 ||...
    abs(rotError(1)) > 0.25 && abs(rotError(2)) > 0.5 && abs(rotError(3)) < 0.5 ||...
    abs(rotError(1)) > 0.25 && abs(rotError(2)) < 0.5 && abs(rotError(3)) < 0.5
    
    if uError >= 0.25
        uError = DesiredU - CurrentU;
    elseif uError <= -0.25
        uError = DesiredU + CurrentU;
    end

    if vError >= 0.25
        vError = DesiredV - CurrentV;
    elseif vError <= -0.25
        vError = DesiredV + CurrentV;
    end

    if wError >= 0.25
        wError = DesiredW - CurrentW;
    elseif wError <= -0.25
        wError = DesiredW + CurrentW;
    end

    CurrentU = OptiTrak_Data(obj, 'U');
    CurrentV = OptiTrak_Data(obj, 'V');
    CurrentW = OptiTrak_Data(obj, 'W');

    uPositionArray = [uPositionArray, CurrentU];
    vPositionArray = [vPositionArray, CurrentV];
    wPositionArray = [wPositionArray, CurrentW];

    CurrentTime = round(toc, 2);
    timeArray = [timeArray, CurrentTime];
    stepArray = [stepArray, n];

    CurrentU = round(abs(CurrentU), 2); CurrentV = round(abs(CurrentV), 2); CurrentW = round(abs(CurrentW), 2);
    
    HexaPosU = round(C887.qPOS('U'), 2); HexaPosV = round(C887.qPOS('V'), 2); HexaPosW = round(C887.qPOS('W'), 2);
    
    DesiredU = round(DesiredU, 2); DesiredV = round(DesiredV, 2); DesiredW = round(DesiredW, 2);

    uError = round(uError, 2); vError = round(vError, 2); wError = round(wError, 2);
    
    tableVals = table(n', CurrentTime', uError', vError', wError', CurrentU', CurrentV', CurrentW', HexaPosU', HexaPosV', HexaPosW', DesiredU', DesiredV', DesiredW');
    tableVals.Properties.VariableNames = {'Step', 'Time', 'U-Err', 'V-Err', 'W-Err', 'Pos-U', 'Pos-V', 'Pos-W', 'Hex-U', 'Hex-V', 'Hex-W', 'Des-U', 'Des-V', 'Des-W'};
    disp(tableVals)

    uErrorArray = [uErrorArray, uError];
    vErrorArray = [vErrorArray, vError];
    wErrorArray = [wErrorArray, wError];

    uHexaPosArray = [uHexaPosArray, HexaPosU];
    vHexaPosArray = [vHexaPosArray, HexaPosV];
    wHexaPosArray = [wHexaPosArray, HexaPosW];

    normPos = norm([uError, vError, wError]);
    normHex = norm([HexaPosU, HexaPosV, HexaPosW]);

    normPosArray = [normPosArray, normPos];
    normHexArray = [normHexArray, normHex];

    if uError >= 0.5
        C887.MOV('U', 0.1*n)
    elseif uError <= -0.5
        C887.MOV('U', -0.1*n)
    end

    if vError >= 0.5
        C887.MOV('V', 0.1*n)
    elseif vError <= -0.5
        C887.MOV('V', -0.1*n)
    end

    if wError >= 0.5
        C887.MOV('W', 0.1*n)
    elseif wError <= -0.5
        C887.MOV('W', -0.1*n)
    end
    
    n = n+1;
    if abs(uError) < 0.4 && abs(vError) < 0.4 && abs(wError) < 0.4
        break;
    end
end

% Creating time-step interval arrays

xTime = timeArray;
yTime = timeArray;
zTime = timeArray;

%%%%%%%%%%%%%%%% PLOT RESULTS IN STEPS %%%%%%%%%%%%%%%%
if Plot_Step == 'Y'

    % X-Value Plots
    subplot(3,2,1)
    plot(xStepArray, xPositionArray,'LineWidth',1,'Color','b')
    hold on;
    plot(xStepArray, xHexaPosArray, 'LineWidth',1,'Color','r')
    legend('OptiTrack Position','Hexapod True Position', 'location', 'northwest')
    title('OptiTrack vs Hexapod Position [x]')
    xlabel('Step #')
    ylabel('Position (mm)')

    absoluteValuePlotX = ((xHexaPosArray - xPositionArray)./xHexaPosArray) .* 100;

    subplot(3,2,2)
    plot(xStepArray(10:end),absoluteValuePlotX(10:end),'LineWidth',1,'Color',"#7E2F8E")
    title('Percentage Error for X')
    xlabel('Step #')
    ylabel('Position (mm)')

    % Y-Value Plots
    subplot(3,2,3)
    plot(yStepArray, yPositionArray, 'LineWidth', 1, 'Color', 'b')
    hold on;
    plot(yStepArray, yHexaPosArray, 'LineWidth', 1, 'Color', 'r')
    legend('OptiTrack Position', 'Hexapod True Position', 'location', 'northwest')
    title('OptiTrack vs Hexapod Position [y]')
    xlabel('Step #')
    ylabel('Position (mm)')

    absoluteValuePlotY = ((yHexaPosArray - yPositionArray)./yHexaPosArray) .* 100;

    subplot(3,2,4)
    plot(yStepArray(10:end),absoluteValuePlotY(10:end),'LineWidth',1,'Color',"#7E2F8E")
    title('Percentage Error for Y')
    xlabel('Step #')
    ylabel('Position (mm)')

    % Z-Value Plots
    subplot(3,2,5)
    plot(zStepArray, zPositionArray,'LineWidth',1,'Color','b')
    hold on;
    plot(zStepArray, zHexaPosArray, 'LineWidth',1,'Color','r')
    legend('OptiTrack Position','Hexapod True Position', 'location', 'northwest')
    title('OptiTrack vs Hexapod Position [z]')
    xlabel('Step #')
    ylabel('Position (mm)')

    absoluteValuePlotZ = ((zHexaPosArray - zPositionArray)./zHexaPosArray) .* 100;

    subplot(3,2,6)
    plot(zStepArray(10:end),absoluteValuePlotZ(10:end),'LineWidth',1,'Color',"#7E2F8E")
    title('Percentage Error for Z')
    xlabel('Step #')
    ylabel('Position (mm)')

    hold off

end


%%%%%%%%%%%%%%%% PLOT RESULTS IN TIME %%%%%%%%%%%%%%%%

if Plot_Time == 'Y'

    figure(2);

    % X-Value Plots
    if movementArray(1) > 0 || movementArray(1) < 0
        subplot(4,2,1)
        plot(xTime, xPositionArray,'LineWidth',1,'Color','b')
        hold on;
        plot(xTime, xHexaPosArray, 'LineWidth',1,'Color','r')
        legend('OptiTrack Position','Hexapod True Position', 'location', 'northwest')
        title('OptiTrack vs Hexapod Position [x]')
        xlabel('Time (s)')
        ylabel('Position (mm)')

        absoluteValuePlotX = ((xHexaPosArray - xPositionArray)./xHexaPosArray) .* 100;

        subplot(4,2,2)
        plot(xTime(10:end),absoluteValuePlotX(10:end),'LineWidth',1,'Color',"#7E2F8E")
        title('Percentage Error for X')
        xlabel('Time (s)')
        ylabel('Position (mm)')
    end

    % Y-Value Plots
    if movementArray(2) > 0 || movementArray(2) < 0
        subplot(4,2,3)
        plot(yTime, yPositionArray, 'LineWidth', 1, 'Color', 'b')
        hold on;
        plot(yTime, yHexaPosArray, 'LineWidth', 1, 'Color', 'r')
        legend('OptiTrack Position', 'Hexapod True Position', 'location', 'northwest')
        title('OptiTrack vs Hexapod Position [y]')
        xlabel('Time (s)')
        ylabel('Position (mm)')

        absoluteValuePlotY = ((yHexaPosArray - yPositionArray)./yHexaPosArray) .* 100;

        subplot(4,2,4)
        plot(yTime(10:end),absoluteValuePlotY(10:end),'LineWidth',1,'Color',"#7E2F8E")
        title('Percentage Error for Y')
        xlabel('Time (s)')
        ylabel('Position (mm)')
    end

    % Z-Value Plots
    if movementArray(3) > 0 || movementArray(3) < 0
        subplot(4,2,5)
        plot(zTime, zPositionArray,'LineWidth',1,'Color','b')
        hold on;
        plot(zTime, zHexaPosArray, 'LineWidth',1,'Color','r')
        legend('OptiTrack Position','Hexapod True Position', 'location', 'northwest')
        title('OptiTrack vs Hexapod Position [z]')
        xlabel('Time (s)')
        ylabel('Position (mm)')

        absoluteValuePlotZ = ((zHexaPosArray - zPositionArray)./zHexaPosArray) .* 100;

        subplot(4,2,6)
        plot(zTime(10:end),absoluteValuePlotZ(10:end),'LineWidth',1,'Color',"#7E2F8E")
        title('Percentage Error for Z')
        xlabel('Time (s)')
        ylabel('Position (mm)')
        hold off
    end
    
    subplot(4,2,7)
    plot(timeArray(5:end), normPosArray(5:end), 'linewidth', 1, 'color', 'b')
    title('Magnitude of Error')
    legend('Magnitude of OptiTrack Error')
    xlabel('Time (s)')
    ylabel('Error')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rigidBody_Pos] = OptiTrak_Data(obj,input_axis) %Pulls current position of indicated axis from Motive

data = obj.getFrame;

rigidBodyX= data.RigidBodies(1).x * 1000;
rigidBodyY= data.RigidBodies(1).y * 1000;
rigidBodyZ= data.RigidBodies(1).z * 1000;


switch input_axis

    case 'X'
        rigidBody_Pos = rigidBodyX;
    case 'Y'
        rigidBody_Pos = rigidBodyY;
    case 'Z'
        rigidBody_Pos = rigidBodyZ;

end

end