
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                                S-Kubed 2024                             %
%                                                                         %
%              Script that iterates perturbation experiment               %
%              for volume-sample collection using Hexapod &               %
%                               OptiTrack Sensors                         %
%                                                                         %
%                   Written by Andre Turpin & Matt Portugal               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%% Documentation %%%%%%%%%%%%%%%%%%%%%%%%%%  %%
%                                                                         %
%                      Note: This script exclusively uses                 %
%                       randmoly-selected perturbations                   %
%                                                                         %
%                              File Dependencies:                         %
%                                                                         %
%           "Rotational_Motion.m" ; "Translational_Motion.m" ;            %
%   "HexaTrack_GUI.mlapp" ; "OptiTrak_Data.m" ; "Connection2Hexapod.m" ;  %
%                           "natnet.m" ; "quaternion.m" ; "               %
%                                                                         %
%                            MATLAB Version: R2023b                       %
%           *This script depends on the installation for MATLAB drivers   %
%           of Physik Instrumente's proprietary software, MikroMove,      %
%             which communicates to the Hexapod in the GSC Language.      %
%                                                                         %
%                Additionally, the Motive motion-tracking software        %
%                uses a data-streaming server, "NatNet" which is          %
%        required to be setup via an SDK prior to running this program.   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%  Hardware Initialization [Run Once] %%%%%%%%%%%%%  %%

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

% Connect to Motive

app.STATUSLabel.FontSize = 14;
app.STATUSLabel.Text = 'Initializing NatNet...';

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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%  Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%  %%

clc; close all; clearvars -except C887 Controller devicesTcpIp ip matlabDriverPath port stageType use_TCPIP_Connection

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Program Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sampleSize = 50; % # of times to iterate both codes

avgErrorArray_ROT = zeros(length(sampleSize));
avgErrorArray_TRA = zeros(length(sampleSize));
randValueArray_ROT = zeros(length(sampleSize));
randValueArray_TRA = zeros(length(sampleSize));

%% %%%%%%%%%%%%%%%%%%%%%%%%%% Program Iteration %%%%%%%%%%%%%%%%%%%%%%%% %%

for w = 1:length(sampleSize)

    %%%%%%%%%%%%%%%%%% START OF ROTATIONAL MOTION %%%%%%%%%%%%%%%%%%%

    disp('Running Rotational Code...')
    uDist = (rand() * 18) - 9;
    if uDist > 9 || uDist < -9
        movementArray = [uDist, 0, 0];
    elseif uDist <= 9 && uDist > 7 || uDist < -7 && uDist >= -9
        vDist = (rand() * 18) - 9;
        movementArray = [uDist, vDist, 0];
    elseif uDist <= 7 || uDist <= -7
        vDist = (rand() * 14) - 7;
        wDist = (rand() * 14) - 7;
        movementArray = [uDist, vDist, wDist];
    end

    randValueArray_ROT(w) = movementArray;

    % Establish Initial Positions as read by Motive
    InitialU = (OptiTrak_Data(obj,'U'))/10;
    InitialV = (OptiTrak_Data(obj,'V'))/10;
    InitialW = (OptiTrak_Data(obj,'W'))/10;

    DesiredU = 0;
    DesiredV = 0;
    DesiredW = 0;

    % Adjust desired positions for any initial offset
    displacementU = DesiredU - InitialU;
    displacementV = DesiredV - InitialV;
    displacementW = DesiredW - InitialW;

    % Update current position to the initial position
    CurrentU = abs(InitialU);
    CurrentV = abs(InitialV);
    CurrentW = abs(InitialW);

    % Compute Error at initial position
    uError = DesiredU - movementArray(1);
    vError = DesiredV - movementArray(2);
    wError = DesiredW - movementArray(3);

    fprintf('The initial error prior to movement is: \n')
    fprintf('U-Error: [%0.3f]  V-Error: [%0.3f]  W-Error: [%0.3f]\n\n',uError,vError,wError)

    % Initialize Arrays
    uPositionArray = zeros(); vPositionArray = zeros(); wPositionArray = zeros();
    stepArray = zeros();
    timeArray = zeros();
    uErrorArray = zeros(); vErrorArray = zeros(); wErrorArray = zeros();
    uHexaPosArray = zeros(); vHexaPosArray = zeros(); wHexaPosArray = zeros();
    normPosArray = zeros();
    normHexArray = zeros();

    absoluteValuePlot1 = zeros(); absoluteValuePlot2 = zeros(); absoluteValuePlot3 = zeros();
    absoluteValuePlotU = zeros(); absoluteValuePlotV = zeros(); absoluteValuePlotW = zeros();

    %%% Perturbing Hexapod Before Moving to Origin
    fprintf('Perturbing Hexapod...')
    C887.MOV('U', movementArray(1));
    C887.MOV('V', movementArray(2));
    C887.MOV('W', movementArray(3));
    pause(5)

    unit = 'deg';
    syms u v w
    axes = [u,v,w];

    % Reset iterator
    n = 1;
    tic;
    rotError = [uError, vError, wError];

    while abs(rotError(1)) > 0.25 && abs(rotError(2)) > 0.25 && abs(rotError(3)) > 0.25 ||...
            abs(rotError(1)) > 0.25 && abs(rotError(2)) > 0.5 && abs(rotError(3)) < 0.5 ||...
            abs(rotError(1)) > 0.25 && abs(rotError(2)) < 0.5 && abs(rotError(3)) < 0.5

        CurrentU = OptiTrak_Data(obj, 'U');
        CurrentV = OptiTrak_Data(obj, 'V');
        CurrentW = OptiTrak_Data(obj, 'W');

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

        uPositionArray = [uPositionArray, CurrentU];
        vPositionArray = [vPositionArray, CurrentV];
        wPositionArray = [wPositionArray, CurrentW];

        CurrentTime = round(toc, 2);
        timeArray = [timeArray, CurrentTime];
        stepArray = [stepArray, n];

        CurrentU = round(abs(CurrentU), 2);
        CurrentV = round(abs(CurrentV), 2);
        CurrentW = round(abs(CurrentW), 2);

        HexaPosU = round(C887.qPOS('U'), 2);
        HexaPosV = round(C887.qPOS('V'), 2);
        HexaPosW = round(C887.qPOS('W'), 2);

        DesiredU = round(DesiredU, 2);
        DesiredV = round(DesiredV, 2);
        DesiredW = round(DesiredW, 2);

        uError = round(uError, 2);
        vError = round(vError, 2);
        wError = round(wError, 2);

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
            C887.MOV('U', 0.01*n)
        elseif uError <= -0.5
            C887.MOV('U', -0.01*n)
        end

        if vError >= 0.5
            C887.MOV('V', 0.01*n)
        elseif vError <= -0.5
            C887.MOV('V', -0.01*n)
        end

        if wError >= 0.5
            C887.MOV('W', 0.01*n)
        elseif wError <= -0.5
            C887.MOV('W', -0.01*n)
        end

        n = n+1;
        if abs(uError) < 0.5 && abs(vError) < 0.5 && abs(wError) < 0.5
            break;
        end

    end

    %%% Calculating Angular Velocity / Velocity %%%
    timeVel = (timeArray(1:end-1) + timeArray(2:end)) / 2;
    posVelocity = velocityCalc(uPositionArray, vPositionArray, wPositionArray, timeArray);
    hexVelocity = velocityCalc(uHexaPosArray, vHexaPosArray, wHexaPosArray, timeArray);
    velTitle = 'Average Angular Velocity vs. Time';
    velMethod = 'Angular Velocity (deg/s)';

    %%% Adjusting Values for Plotting %%%
    xVals = timeArray;
    method = 'Time (s)';

    firstPosArray = uPositionArray;
    firstHexArray = uHexaPosArray;
    secondPosArray = vPositionArray;
    secondHexArray = vHexaPosArray;
    thirdPosArray = wPositionArray;
    thirdHexArray = wHexaPosArray;

    absoluteValuePlot1 = zeros(1, n);
    absoluteValuePlot2 = zeros(1, n);
    absoluteValuePlot3 = zeros(1, n);

    absoluteValuePlotU = zeros(1, n);
    absoluteValuePlotV = zeros(1, n);
    absoluteValuePlotW = zeros(1, n);

    for i = 1:length(absoluteValuePlot1)
        totalPercError(i) = (absoluteValuePlot1(i) + absoluteValuePlot2(i) + absoluteValuePlot3(i))/3;
    end

    % Save Values to Looped Matrix
    avgErrorArray_ROT(w) = mean(totalPercError);


    %%%%%%%%%%%%%%%%%% END OF ROTATIONAL MOTION %%%%%%%%%%%%%%%%%%%

    % Re-Center Hexapod without FRF
    C887.MOV('X',0)
    C887.MOV('Y',0)
    C887.MOV('Z',0)
    pause(2)

    disp('Rotational Code Complete. Continuing with Translational...')
    pause(1)

    %%%%%%%%%%%%%%%% START OF TRANSLATIONAL MOTION %%%%%%%%%%%%%%%%

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
    
    randValueArray_TRA(w) = movementArray;

    % Establish Initial Positions as read by Motive
    InitialX = (OptiTrak_Data(obj,'X'))/10;
    InitialY = (OptiTrak_Data(obj,'Y'))/10;
    InitialZ = (OptiTrak_Data(obj,'Z'))/10;

    DesiredX = 0;
    DesiredY = 0;
    DesiredZ = 0;

    % Adjust desired positions for any initial offset
    displacementX = DesiredX - InitialX;
    displacementY = DesiredY - InitialY;
    displacementZ = DesiredZ - InitialZ;

    % Update current position to the initial position
    CurrentX = abs(InitialX);
    CurrentY = abs(InitialY);
    CurrentZ = abs(InitialZ);

    % Compute Error at initial position
    xError = DesiredX - movementArray(1);
    yError = DesiredY - movementArray(2);
    zError = DesiredZ - movementArray(3);

    fprintf('\nThe initial error prior to movement is: \n')
    fprintf('X-Error: [%0.3f]  Y-Error: [%0.3f]  Z-Error: [%0.3f]\n\n',xError,yError,zError)

    % Initialize Arrays
    xPositionArray = zeros(); yPositionArray = zeros(); zPositionArray = zeros();
    xHexaPosArray = zeros(); yHexaPosArray = zeros(); zHexaPosArray = zeros();
    stepArray = zeros();
    timeArray = zeros();
    xErrorArray = zeros(); yErrorArray = zeros(); zErrorArray = zeros();
    normPosArray = zeros();
    normHexArray = zeros();

    absoluteValuePlot1 = zeros(); absoluteValuePlot2 = zeros(); absoluteValuePlot3 = zeros();
    absoluteValuePlotU = zeros(); absoluteValuePlotV = zeros(); absoluteValuePlotW = zeros();

    %%% Perturbing Hexapod Before Moving to Origin
    fprintf('Perturbing Hexapod...')
    C887.MOV('X', movementArray(1));
    C887.MOV('Y', movementArray(2));
    C887.MOV('Z', movementArray(3));
    pause(5)

    unit = 'mm';
    syms x y z
    axes = [x,y,z];

    % Reset iterator
    n = 1;
    tic;
    Error = [xError, yError, zError];

    while abs(Error(1)) > 0.25 && abs(Error(2)) > 0.25 && abs(Error(3)) > 0.25 ||...
            abs(Error(1)) > 0.25 && abs(Error(2)) > 0.5 && abs(Error(3)) < 0.5 ||...
            abs(Error(1)) > 0.25 && abs(Error(2)) < 0.5 && abs(Error(3)) < 0.5

        CurrentX = OptiTrak_Data(obj, 'X');
        CurrentY = OptiTrak_Data(obj, 'Y');
        CurrentZ = OptiTrak_Data(obj, 'Z');

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

        xPositionArray = [xPositionArray, CurrentX];
        yPositionArray = [yPositionArray, CurrentY];
        zPositionArray = [zPositionArray, CurrentZ];

        CurrentTime = round(toc, 2);
        timeArray = [timeArray, CurrentTime];
        stepArray = [stepArray, n];

        CurrentX = round(CurrentX, 2);
        CurrentY = round(CurrentY, 2);
        CurrentZ = round(CurrentZ, 2);

        DesiredX = round(DesiredX, 2);
        DesiredY = round(DesiredY, 2);
        DesiredZ = round(DesiredZ, 2);

        xError = round(xError, 2);
        yError = round(yError, 2);
        zError = round(zError, 2);

        HexaPosX = round(C887.qPOS('X'), 2);
        HexaPosY = round(C887.qPOS('Y'), 2);
        HexaPosZ = round(C887.qPOS('Z'), 2);

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
            C887.MOV('X', 0.03*n)
        elseif xError <= -0.5
            C887.MOV('X', -0.03*n)
        end

        if yError >= 0.5
            C887.MOV('Y', 0.03*n)
        elseif yError <= -0.5
            C887.MOV('Y', -0.03*n)
        end

        if zError >= 0.5
            C887.MOV('Z', 0.03*n)
        elseif zError <= -0.5
            C887.MOV('Z', -0.03*n)
        end

        n = n+1;
        if abs(xError) < 0.5 && abs(yError) < 0.5 && abs(zError) < 0.5
            break;
        end

    end

    %%% Calculating Angular Velocity / Velocity %%%
    timeVel = (timeArray(1:end-1) + timeArray(2:end)) / 2;
    posVelocity = velocityCalc(xPositionArray, yPositionArray, zPositionArray, timeArray);
    hexVelocity = velocityCalc(xHexaPosArray, yHexaPosArray, zHexaPosArray, timeArray);
    velTitle = 'Average Velocity vs. Time';
    velMethod = 'Velocity (mm/s)';

    %%% Adjusting Values for Plotting %%%
    xVals = timeArray;
    method = 'Time (s)';
    firstPosArray = xPositionArray;
    firstHexArray = xHexaPosArray;
    secondPosArray = yPositionArray;
    secondHexArray = yHexaPosArray;
    thirdPosArray = zPositionArray;
    thirdHexArray = zHexaPosArray;

    absoluteValuePlot1 = zeros(1, n);
    absoluteValuePlot2 = zeros(1, n);
    absoluteValuePlot3 = zeros(1, n);

    absoluteValuePlotU = zeros(1, n);
    absoluteValuePlotV = zeros(1, n);
    absoluteValuePlotW = zeros(1, n);

    for i = 1:length(absoluteValuePlot1)
        totalPercError(i) = (absoluteValuePlot1(i) + absoluteValuePlot2(i) + absoluteValuePlot3(i))/3;
    end

    % Save Values to Looped Matrix
    avgErrorArray_TRA(w) = mean(totalPercError);
end

%% %%%%%%%%%%%%%%%%%%% Display Volume-Sample Results %%%%%%%%%%%%%%%%%%% %%

figure(1)

subplot(2,1,1)
plot(sampleSize, avgErrorArray_ROT,'Color','r')
hold on
plot(sampleSize, avgErrorArray_TRA,'Color','b')
grid on
hold off
title('Error Analysis for n Samples')
legend on

subplot(2,1,2)
plot(avgErrorArray_ROT,randValueArray_ROT)
hold on
plot(avgErrorArray_TRA,randValueArray_TRA)
grid on
hold off
title('Error Analysis with randomized perturbations')
legend on



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


