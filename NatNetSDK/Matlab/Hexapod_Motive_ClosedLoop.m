%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   S-Kubed 2024                 %
%     Written by Andre Turpin & Matt Portugal    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; close all; clearvars -except C887 Controller devicesTcpIp ip matlabDriverPath port stageType use_TCPIP_Connection

% Note: Hexapod moves an average of 0.0977mm per step

%%%%%%%%%%%%%%%%%%% Check if Motive is Open %%%%%%%%%%%%%%%%%%%

% WiP

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

%%%%%%%%%%%%%%%% Prompt User Input for Desired Position %%%%%%%%%%%%%%%%

xDist = 0;
yDist = 0;
zDist = 0;

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

%%%%%%%%%%%%%%%% Establish Initial Positions as read by Motive %%%%%%%%%%%%%%%%

% Initial_Position = OptiTrak_Data(obj,input_axis);
% Initial_Position = Initial_Position / 10; % Convert to mm
% Initial_Position = abs(Initial_Position)

InitialX = (OptiTrak_Data(obj,'X'))/10;
InitialY = (OptiTrak_Data(obj,'Y'))/10;
InitialZ = (OptiTrak_Data(obj,'Z'))/10;

%%%%%%%%%%%%%%%% Start Control Loop %%%%%%%%%%%%%%%%

% Initial Conditions
% DesiredPos = str2num(input_Pos); %0.5cm
% DesiredPos = DesiredPos - Initial_Position
% CurrentPos = Initial_Position;
% Error = DesiredPos - CurrentPos;

% Define the desired positions
DesiredX = xDist;
DesiredY = yDist;
DesiredZ = zDist;

% Adjust desired positions for any initial offset
displacementX = DesiredX - InitialX;
displacementY = DesiredY - InitialY;
displacementZ = DesiredZ - InitialZ;

% Update current position to the initial position
CurrentX = abs(InitialX);
CurrentY = abs(InitialY);
CurrentZ = abs(InitialZ);

% Compute Error at initial position
xError = DesiredX - CurrentX;
yError = DesiredY - CurrentY;
zError = DesiredZ - CurrentZ;

fprintf('The initial error prior to movement is: \n')
fprintf('X-Error: [%0.3f]  Y-Error: [%0.3f]  Z-Error: [%0.3f]',xError,yError,zError)

% Initialize Arrays for Plots
xPositionArray = zeros();
yPositionArray = zeros();
zPositionArray = zeros();

xStepArray = zeros();
yStepArray = zeros();
zStepArray = zeros();

xErrorArray = zeros();
yErrorArray = zeros();
zErrorArray = zeros();

xHexaPosArray = zeros();
yHexaPosArray = zeros();
zHexaPosArray = zeros();

% Reset iterator
n = 1;

while xError >= 0.25
    xError = DesiredX - CurrentX;
    CurrentX = OptiTrak_Data(obj,'X');
    CurrentX = abs(CurrentX);

    HexaPosX = C887.qPOS('X');
    fprintf('--------------------------------------------- \n')
    fprintf('Step | X-Error | CurrentPos | DesiredPos | HexapodPos \n')
    fprintf('  %d | %0.3f |  %0.3f  |  %0.3f  | %0.3f \n',n,xError,CurrentX,DesiredX, HexaPosX)
  
    % Save Values to Arrays
    xPositionArray = [xPositionArray, CurrentX];
    xStepArray = [xStepArray,n];
    xErrorArray = [xErrorArray,xError];
    xHexaPosArray = [xHexaPosArray, HexaPosX];
    
    C887.MOV('X',0.1 * n)
    % disp(C887.qPOS('X'))
    n = n + 1;

end

pause(2)
fprintf('\n \n  X-Direction has been corrected, continuing to the Y-Direction... \n \n \n')

% Reset iterator
n = 1;

while yError >= 0.25
    yError = DesiredY - CurrentY;
    CurrentY = OptiTrak_Data(obj,'Y');
    CurrentY = abs(CurrentY);

    HexaPosY = C887.qPOS('Y');
    fprintf('--------------------------------------------- \n')
    fprintf('Step | Y-Error | CurrentPos | DesiredPos | HexapodPos \n')
    fprintf('  %d | %0.3f |  %0.3f  |  %0.3f  | %0.3f \n',n,yError,CurrentY,DesiredY, HexaPosY)
    
    % Save Values to Arrays
    yPositionArray = [yPositionArray, CurrentY];
    yStepArray = [yStepArray,n];
    yErrorArray = [yErrorArray,yError];
    yHexaPosArray = [yHexaPosArray, HexaPosY];

    C887.MOV('Y',0.1 * n)
    % disp(C887.qPOS('X'))
    n = n + 1;

end

pause(2)
fprintf('\n \n  Y-Direction has been corrected, continuing to the Z-Direction... \n \n \n')

% Reset iterator
n = 1;

while zError >= 0.25
    zError = DesiredZ - CurrentZ;
    CurrentZ = OptiTrak_Data(obj,'Z');
    CurrentZ = abs(CurrentZ);

    HexaPosZ = C887.qPOS('Z');
    fprintf('--------------------------------------------- \n')
    fprintf('Step | Z-Error | CurrentPos | DesiredPos | HexapodPos \n')
    fprintf('  %d | %0.3f |  %0.3f  |  %0.3f  | %0.3f \n',n,zError,CurrentZ,DesiredZ, HexaPosZ)
    
    % Save Values to Arrays
    zPositionArray = [zPositionArray, CurrentZ];
    zStepArray = [zStepArray,n];
    zErrorArray = [zErrorArray,zError];
    zHexaPosArray = [zHexaPosArray, HexaPosZ];

    C887.MOV('Z',0.1 * n)
    % disp(C887.qPOS('X'))
    n = n + 1;

end


%%%%%%%%%%%%%%%% Plot Results %%%%%%%%%%%%%%%%

% Plot Results
figure(1)

% X-Value Plots
subplot(3,2,1)
plot(xStepArray, xPositionArray,'LineWidth',1,'Color','b')
hold on;
plot(xStepArray, xHexaPosArray, 'LineWidth',1,'Color','r')
legend('OptiTrack Position','Hexapod True Position')
title('OptiTrack vs Hexapod Position [x]')

absoluteValuePlotX = ((xHexaPosArray - xPositionArray)./xHexaPosArray) .* 100; 

subplot(3,2,2)
plot(xStepArray(10:end),absoluteValuePlotX(10:end),'LineWidth',1,'Color',"#7E2F8E")
title('Percentage Error for X')

% Y-Value Plots
subplot(3,2,3) 
plot(yStepArray, yPositionArray, 'LineWidth', 1, 'Color', 'b')
hold on;
plot(yStepArray, yHexaPosArray, 'LineWidth', 1, 'Color', 'r')
legend('OptiTrack Position', 'Hexapod True Position')
title('OptiTrack vs Hexapod Position [y]')

absoluteValuePlotY = ((yHexaPosArray - yPositionArray)./yHexaPosArray) .* 100; 

subplot(3,2,4)
plot(yStepArray(10:end),absoluteValuePlotY(10:end),'LineWidth',1,'Color',"#7E2F8E")
title('Percentage Error for Y')

% Z-Value Plots
subplot(3,2,5) 
plot(zStepArray, zPositionArray,'LineWidth',1,'Color','b')
hold on;
plot(zStepArray, zHexaPosArray, 'LineWidth',1,'Color','r')
legend('OptiTrack Position','Hexapod True Position')
title('OptiTrack vs Hexapod Position [z]')

absoluteValuePlotZ = ((zHexaPosArray - zPositionArray)./zHexaPosArray) .* 100; 

subplot(3,2,6)
plot(zStepArray(10:end),absoluteValuePlotZ(10:end),'LineWidth',1,'Color',"#7E2F8E")
title('Percentage Error for Z')




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