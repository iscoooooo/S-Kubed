clc; close all; clearvars -except C887 Controller devicesTcpIp ip matlabDriverPath port stageType use_TCPIP_Connection

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

% % Initialize arrays to store data
% frameData = zeros(1, numFrames);
% timeData = zeros(1, numFrames);
% rigidBodyNames = cell(1, model.RigidBodyCount);
% rigidBodyX  = zeros(numFrames, model.RigidBodyCount);
% rigidBodyY  = zeros(numFrames, model.RigidBodyCount);
% rigidBodyZ  = zeros(numFrames, model.RigidBodyCount);
% rigidBodyRoll = zeros(numFrames, model.RigidBodyCount);
% rigidBodyPitch = zeros(numFrames, model.RigidBodyCount);
% rigidBodyYaw = zeros(numFrames, model.RigidBodyCount);


%%%%%%%%%%%%%%%% Prompt User Input for Desired Position %%%%%%%%%%%%%%%%

prompt = "\n > Enter desired axis to move (X/Y/Z/U/V/W) \n \n >> ";
input_axis = input(prompt,"s");
if isempty(input_axis)
    input_axis = 'Y'; 
end

if input_axis == 'X' || input_axis == 'Y' || input_axis == 'Z' || input_axis == 'U' || input_axis == 'V' || input_axis == 'W'
    fprintf('\n Commanded axis to move is: %s\n \n',input_axis);

else
    disp('ERROR: Axis not recognized, please enter from X,Y,Z,U,V,W')
end

prompt2 = "\n > Enter desired movement (in mm) \n \n >> ";
input_Pos = input(prompt2,"s");
fprintf('\n Commanded desired position: %s mm \n',input_Pos);


%%%%%%%%%%%%%%%% Establish Initial Position as read by Motive %%%%%%%%%%%%%%%%

Initial_Position = OptiTrak_Data(obj,input_axis);
Initial_Position = Initial_Position / 10; % Convert to mm
Initial_Position = abs(Initial_Position)

%%%%%%%%%%%%%%%% Start Condition Loop %%%%%%%%%%%%%%%%

% Initial Conditions 
DesiredPos = str2num(input_Pos); %0.5cm
DesiredPos = DesiredPos;
DesiredPos = DesiredPos - Initial_Position
CurrentPos = Initial_Position;
Error = DesiredPos - CurrentPos;


fprintf('The initial error prior to movement is %d \n \n',Error)
n = 1;

while Error >= 0.2

  Error = DesiredPos - CurrentPos; %Recheck error
    CurrentPos = OptiTrak_Data(obj,input_axis);
    CurrentPos = abs(CurrentPos);
  
HexaPos = C887.qPOS('X');
fprintf('--------------------------------------------- \n')
fprintf('Step | Error | CurrentPos | DesiredPos | HexapodPos \n')
fprintf('  %d | %0.3f |  %0.3f  |  %0.3f  | %0.3f \n',n,Error,CurrentPos,DesiredPos, HexaPos)
% dataArray{n + 1} = {n, Error, CurrentPos, DesiredPos};

C887.MOV(input_axis,0.1 * n) 
% disp(C887.qPOS('X'))
n = n + 1;

end


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