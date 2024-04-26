%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S-Kubed 2024
% Written by Andre Turpin & Matt Portugal
clc; close all; clearvars -except C887 Controller devicesTcpIp ip matlabDriverPath port stageType use_TCPIP_Connection
%
%
% 
%
% Note: Hexapod moves an average of 0.0977mm per step
%

app = HexaTrack_GUI;
pause(2)

Rotational = 'N';
Translational = 'Y';

Plot_Time = 'Y';
Plot_Step = 'N';
PerturbationType = 0;

UserInputX = 0;
UserInputY = 0;
UserInputZ = 0;

while PerturbationType == 0
    pause(1)
    app.STATUSLabel.FontSize = 14;
    app.STATUSLabel.Text = 'Waiting for Perturbation...';
    disp('Waiting for Perturbation Type selection...')
    app.Lamp.Color = 'r';
    drawnow;
end

if PerturbationType == 1
    Perturbation = 'Random'; % 'User' or 'Random'
    app.STATUSLabel.FontSize = 14;
    app.STATUSLabel.Text = 'Perturbation Selected...';
elseif PerturbationType == 2
    Perturbation = 'User';
    app.STATUSLabel.FontSize = 14;
    app.STATUSLabel.Text = 'Perturbation Selected...';
    pause(2)
    drawnow;
        while UserInputX == 0 && UserInputY == 0 && UserInputZ == 0
        pause(1)
          app.STATUSLabel.Text = 'Waiting for Input...';
          disp('Waiting for Input')
          disp(UserInputX)
          app.Lamp.Color = 'b';
%           if UserInputX ~= 0
%               return
%           elseif UserInputY ~= 0
%               return
%           elseif UserInputZ
        end
    app.STATUSLabel.Text = 'Perturbation Selected...';
    app.Lamp.Color = 'g';
end



app.Lamp.Color = 'g';
app.Label_2.Text = Perturbation;
drawnow;

%%%%%%%%%%%%%%%%%%% Hexapod Initialization %%%%%%%%%%%%%%%%%%%

app.STATUSLabel.FontSize = 14;
app.STATUSLabel.Text = 'Checking Hexapod Connection...';

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


%%%%%%%%%%%%%%%% User-Input Perturbation %%%%%%%%%%%%%%%%
if strcmp(Translational,'Y') == true
    if strcmp(Perturbation,'User') == true

%         xDist = 0;
%         yDist = 0;
%         zDist = 0;
%         axisCount = 0;
            
            xDist = UserInputX;
            yDist = UserInputY;
            zDist = UserInputZ;

%         fprintf('\nMax X: +/- 49 mm\n\n');
%         xDist = input('Enter Movement in X-Direction: ');

        if xDist > 39 || xDist < -39
            movementArray = [xDist, 0, 0];
        elseif xDist <= 39 && xDist > 16 || xDist < -16 && xDist >= -39
%             fprintf('\nMax Y: +/- 39 mm\n');
%             yDist = input('Enter Movement in Y-Direction: ');
            movementArray = [xDist, yDist, 0];
        elseif xDist <= 16 || xDist <= -16
%             fprintf('\nMax Y: +/- 16 mm\n');
%             yDist = input('Enter Movement in Y-Direction: ');
            fprintf('\nMax Z: +/- 16 mm\n');
%             zDist = input('Enter Movement in Z-Direction: ');
            movementArray = [xDist, yDist, zDist];
        end
    end

    %%%%%%%%%%%%%%%% Randomized Perturbation %%%%%%%%%%%%%%%%

    pause(2)
    if strcmp(Perturbation,'Random') == true
        disp('Perturbing Randomly....')
        app.STATUSLabel.FontSize = 14;
        app.STATUSLabel.Text = 'Perturbing Hexapod...';

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
end

if strcmp(Rotational, 'Y') == true
    if strcmp(Perturbation,'User') == true

        disp('Perturbing User Input....')
        app.STATUSLabel.FontSize = 14;

        uDist = 0;
        vDist = 0;
        wDist = 0;
        axisCount = 0;

        fprintf('\nMax U: +/- 13 deg\n\n');
        uDist = input('Enter Movement in U-Direction: ');

        if uDist > 9 || uDist < -9
            movementArray = [uDist, 0, 0];
        elseif uDist <= 9 && uDist > 7 || uDist < -7 && uDist >= -9
            fprintf('\nMax V: +/- 9 deg\n');
            yDist = input('Enter Movement in V-Direction: ');
            movementArray = [uDist, yDist, 0];
        elseif uDist <= 7 || uDist <= -7
            fprintf('\nMax V: +/- 7 deg\n');
            vDist = input('Enter Movement in V-Direction: ');
            fprintf('\nMax W: +/- 7 deg\n');
            wDist = input('Enter Movement in W-Direction: ');
            movementArray = [uDist, vDist, wDist];
        end
    end

    %%%%%%%%%%%%%%%% Randomized Perturbation %%%%%%%%%%%%%%%%

    pause(2)
    if strcmp(Perturbation,'Random') == true
        disp('Perturbing Randomly....')
        app.STATUSLabel.FontSize = 14;
        app.STATUSLabel.Text = 'Perturbing Hexapod...';
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

DesiredX = 0;
DesiredY = 0;
DesiredZ = 0;
DesiredU = 0;
DesiredV = 0;
DesiredW = 0;

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
if strcmp(Translational, 'Y') == true
    xError = DesiredX - movementArray(1);
    yError = DesiredY - movementArray(2);
    zError = DesiredZ - movementArray(3);
elseif strcmp(Rotational, 'Y') == true
    uError = DesiredU - movementArray(1);
    vError = DesiredV - movementArray(2);
    wError = DesiredW - movementArray(3);
end

if strcmp(Translational, 'Y') == true
    fprintf('\nThe initial error prior to movement is: \n')
    fprintf('X-Error: [%0.3f]  Y-Error: [%0.3f]  Z-Error: [%0.3f]\n\n',xError,yError,zError)
else
    fprintf('The initial error prior to movement is: \n')
    fprintf('U-Error: [%0.3f]  V-Error: [%0.3f]  W-Error: [%0.3f]\n\n',uError,vError,wError)
end

% Initialize Arrays for Plots
xPositionArray = zeros(); yPositionArray = zeros(); zPositionArray = zeros();
uPositionArray = zeros(); vPositionArray = zeros(); wPositionArray = zeros();

stepArray = zeros();
timeArray = zeros();

xErrorArray = zeros(); yErrorArray = zeros(); zErrorArray = zeros();
uErrorArray = zeros(); vErrorArray = zeros(); wErrorArray = zeros();

xHexaPosArray = zeros(); yHexaPosArray = zeros(); zHexaPosArray = zeros();
uHexaPosArray = zeros(); vHexaPosArray = zeros(); wHexaPosArray = zeros();

normPosArray = zeros();
normHexArray = zeros();

absoluteValuePlot1 = zeros(); absoluteValuePlot2 = zeros(); absoluteValuePlot3 = zeros();
absoluteValuePlotU = zeros(); absoluteValuePlotV = zeros(); absoluteValuePlotW = zeros();


%%% Perturbing Hexapod Before Moving to Origin

fprintf('Perturbing Hexapod...')
app.STATUSLabel.FontSize = 14;
app.STATUSLabel.Text = 'Perturbing Hexapod...';
if strcmp(Translational, 'Y') == true
    C887.MOV('X', movementArray(1));
    C887.MOV('Y', movementArray(2));
    C887.MOV('Z', movementArray(3));
elseif strcmp(Rotational, 'Y') == true
    C887.MOV('U', movementArray(1));
    C887.MOV('V', movementArray(2));
    C887.MOV('W', movementArray(3));
end
pause(5)

%%% Moving Back to Origin

% Translational -----------------------------------------------------------

fprintf('Moving Back to Origin...')
if strcmp(Translational, 'Y') == true
    app.STATUSLabel.FontSize = 14;
    app.STATUSLabel.Text = 'Correcting back to Origin...';

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
end

% Rotational --------------------------------------------------------------

if strcmp(Rotational, 'Y') == true
    app.STATUSLabel.FontSize = 14;
    app.STATUSLabel.Text = 'Correcting back to Origin...';
    drawnow;
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
end

%%% Calculating Angular Velocity / Velocity %%%

app.STATUSLabel.FontSize = 14;
app.STATUSLabel.Text = 'Compiling Data...';

timeVel = (timeArray(1:end-1) + timeArray(2:end)) / 2;

if strcmp(Translational, 'Y') == true
    posVelocity = velocityCalc(xPositionArray, yPositionArray, zPositionArray, timeArray);
    hexVelocity = velocityCalc(xHexaPosArray, yHexaPosArray, zHexaPosArray, timeArray);
    velTitle = 'Average Velocity vs. Time';
    velMethod = 'Velocity (mm/s)';
elseif strcmp(Rotational, 'Y') == true
    posVelocity = velocityCalc(uPositionArray, vPositionArray, wPositionArray, timeArray);
    hexVelocity = velocityCalc(uHexaPosArray, vHexaPosArray, wHexaPosArray, timeArray);
    velTitle = 'Average Angular Velocity vs. Time';
    velMethod = 'Angular Velocity (deg/s)';
end

%%% Adjusting Values for Plotting %%%
app.STATUSLabel.FontSize = 14;
app.STATUSLabel.Text = 'Plotting Results...';
if strcmp(Plot_Step, 'Y') == true
    xVals = stepArray;
    method = 'Step #';
elseif strcmp(Plot_Time, 'Y') == true
    xVals = timeArray;
    method = 'Time (s)';
end

if strcmp(Translational, 'Y') == true
    firstPosArray = xPositionArray;
    firstHexArray = xHexaPosArray;
    secondPosArray = yPositionArray;
    secondHexArray = yHexaPosArray;
    thirdPosArray = zPositionArray;
    thirdHexArray = zHexaPosArray;
elseif strcmp(Rotational, 'Y') == true
    firstPosArray = uPositionArray;
    firstHexArray = uHexaPosArray;
    secondPosArray = vPositionArray;
    secondHexArray = vHexaPosArray;
    thirdPosArray = wPositionArray;
    thirdHexArray = wHexaPosArray;
end

absoluteValuePlot1 = zeros(1, n);
absoluteValuePlot2 = zeros(1, n);
absoluteValuePlot3 = zeros(1, n);

absoluteValuePlotU = zeros(1, n);
absoluteValuePlotV = zeros(1, n);
absoluteValuePlotW = zeros(1, n);

%%%%%%%%%%%%%%%% PLOT RESULTS IN TIME %%%%%%%%%%%%%%%%

app.STATUSLabel.FontSize = 14;
app.STATUSLabel.Text = '   ';
% X or U Value Plots (Translational vs. Rotational)
if movementArray(1) > 0 || movementArray(1) < 0
    %     subplot(4,2,1)
    plot(app.PlotX,xVals(5:end), firstPosArray(5:end),'LineWidth',1,'Color','b')
    hold on;
    plot(app.PlotX,xVals(5:end), firstHexArray(5:end), 'LineWidth',1,'Color','r')
    yline(app.PlotX,0, 'linestyle', '- -', 'color', 'black', 'linewidth', 1.5);
    if movementArray(1) < 0
        legend(app.PlotX,'OptiTrack Position','Hexapod True Position', 'Origin', 'location', 'southeast')
    elseif movementArray(1) > 0
        legend(app.PlotX,'OptiTrack Position','Hexapod True Position', 'Origin', 'location', 'southwest')
    end
    title(app.PlotX,sprintf('OptiTrack vs Hexapod Position [%s]', axes(1)))
    xlabel(app.PlotX,sprintf('%s', method))
    ylabel(app.PlotX,sprintf('Position (%s)', unit))
    grid(app.PlotX,"on")

    absoluteValuePlot1 = ((firstHexArray - firstPosArray)./firstHexArray) .* 100;

    %     subplot(4,2,2)
    plot(app.PlotErrorX,xVals(10:end),flip(absoluteValuePlot1(10:end)),'LineWidth',1,'Color',"#7E2F8E")
    title(app.PlotErrorX,'Percentage Error for X')
    xlabel(app.PlotErrorX,sprintf('%s', method))
    ylabel(app.PlotErrorX,'Percent Error')
    yline(app.PlotErrorX,0, 'linestyle', '- -', 'color', 'black', 'linewidth', 1.5);
    grid(app.PlotErrorX,"on")

end

% Y or V Value Plots (Translational vs. Rotational)
if movementArray(2) > 0 || movementArray(2) < 0
    %     subplot(4,2,3)
    plot(app.PlotY,xVals(5:end), secondPosArray(5:end), 'LineWidth', 1, 'Color', 'b')
    hold on;
    plot(app.PlotY,xVals(5:end), secondHexArray(5:end), 'LineWidth', 1, 'Color', 'r')
    yline(app.PlotY,0, 'linestyle', '- -', 'color', 'black', 'linewidth', 1.5);
    if movementArray(2) < 0
        legend(app.PlotY,'OptiTrack Position','Hexapod True Position', 'Origin', 'location', 'southeast')
    elseif movementArray(2) > 0
        legend(app.PlotY,'OptiTrack Position','Hexapod True Position', 'Origin', 'location', 'southwest')
    end
    title(app.PlotY,sprintf('OptiTrack vs Hexapod Position [%s]', axes(2)))
    xlabel(app.PlotY,sprintf('%s', method))
    ylabel(app.PlotY,sprintf('Position (%s)', unit))
    grid(app.PlotY,"on")


    absoluteValuePlot2 = ((secondHexArray - secondPosArray)./secondHexArray) .* 100;

    %     subplot(4,2,4)
    plot(app.PlotErrorY,xVals(10:end),flip(absoluteValuePlot2(10:end)),'LineWidth',1,'Color',"#7E2F8E")
    title(app.PlotErrorY,'Percentage Error for Y')
    xlabel(app.PlotErrorY,sprintf('%s', method))
    ylabel(app.PlotErrorY,'Percent Error')
    yline(app.PlotErrorY,0, 'linestyle', '- -', 'color', 'black', 'linewidth', 1.5);
    grid(app.PlotErrorY,"on")

end

% Z or W Value Plots (Translational vs. Rotational)
if movementArray(3) > 0 || movementArray(3) < 0
    %     subplot(4,2,5)
    plot(app.PlotZ,xVals(5:end), thirdPosArray(5:end),'LineWidth',1,'Color','b')
    hold on;
    plot(app.PlotZ,xVals(5:end), thirdHexArray(5:end), 'LineWidth',1,'Color','r')
    yline(app.PlotZ,0, 'linestyle', '- -', 'color', 'black', 'linewidth', 1.5);
    if movementArray(3) < 0
        legend(app.PlotZ,'OptiTrack Position','Hexapod True Position', 'Origin', 'location', 'southeast')
    elseif movementArray(3) > 0
        legend(app.PlotZ,'OptiTrack Position','Hexapod True Position', 'Origin', 'location', 'southwest')
    end
    title(app.PlotZ,sprintf('OptiTrack vs Hexapod Position [%s]', axes(3)))
    xlabel(app.PlotZ,sprintf('%s', method))
    ylabel(app.PlotZ,sprintf('Position (%s)', unit))
    grid(app.PlotZ,"on")

    absoluteValuePlot3 = ((thirdHexArray - thirdPosArray)./thirdHexArray) .* 100;

    %     subplot(4,2,6)
    plot(app.PlotErrorZ,xVals(10:end),flip(absoluteValuePlot3(10:end)),'LineWidth',1,'Color',"#7E2F8E")
    title(app.PlotErrorZ,'Percentage Error for Z')
    xlabel(app.PlotErrorZ,sprintf('%s', method))
    ylabel(app.PlotErrorZ,'Percent Error')
    yline(app.PlotErrorZ,0, 'linestyle', '- -', 'color', 'black', 'linewidth', 1.5);
    hold off
    grid(app.PlotErrorZ,"on")

end

for i = 1:length(absoluteValuePlot1)
    totalPercError(i) = norm([absoluteValuePlot1(i) absoluteValuePlot2(i), absoluteValuePlot3(i)]);
end

app.Label.Text = [num2str(min(totalPercError)), '%'];

% subplot(4,2,7)
% plot(xVals(5:end), flip(totalPercError(5:end)), 'linewidth', 1, 'color', 'b')
% title('Magnitude of Error')
% legend('Magnitude of OptiTrack Error')
% xlabel(sprintf('%s', method))
% ylabel('Error')

% subplot(4,2,8)
% plot(timeVel(10:end), posVelocity(10:end), 'linewidth', 1, 'Color', 'b')
% hold on
% plot(timeVel(10:end), hexVelocity(10:end), 'linewidth', 1, 'Color', 'r')
% legend('OptiTrack Velocity', 'Hexapod True Velocity', 'location', 'southeast')
% xlabel(sprintf('%s', method))
% ylabel(sprintf('%s', velMethod))
% title(sprintf('%s', velTitle))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [vTotal] = velocityCalc(ax1, ax2, ax3, time)

dx = diff(ax1);
dy = diff(ax2);
dz = diff(ax3);

dt = diff(time);

vx = dx ./ dt;
vy = dy ./ dt;
vz = dz ./ dt;

vTotal = sqrt(vx.^2 + vy.^2 + vz.^2);

end

function [rigidBody_Pos] = OptiTrak_Data(obj,input_axis) %Pulls current position of indicated axis from Motive

data = obj.getFrame;

rigidBodyX= data.RigidBodies(1).x * 1000;
rigidBodyY= data.RigidBodies(1).y * 1000;
rigidBodyZ= data.RigidBodies(1).z * 1000;

q = quaternion(data.RigidBodies(1).qw, data.RigidBodies(1).qx, ...
    data.RigidBodies(1).qy, data.RigidBodies(1).qz);

eulerAngles = q.EulerAngles('ZYX');

rigidBodyU = eulerAngles(3)* 180/pi;
rigidBodyV = eulerAngles(2)* 180/pi;
rigidBodyW = eulerAngles(1)* 180/pi;

switch input_axis

    case 'X'
        rigidBody_Pos = rigidBodyX;
    case 'Y'
        rigidBody_Pos = rigidBodyY;
    case 'Z'
        rigidBody_Pos = rigidBodyZ;
    case 'U'
        rigidBody_Pos = rigidBodyU;
    case 'V'
        rigidBody_Pos = rigidBodyV;
    case 'W'
        rigidBody_Pos = rigidBodyW;

end

end