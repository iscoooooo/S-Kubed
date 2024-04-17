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
end



%%%%%%%%%%%%%%%%%%% NatNet Initialization %%%%%%%%%%%%%%%%%%%

obj = natnetclient()

if (natnetclient.IsConnected == 0)
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
end

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




%%%%%%%%%%%%%%%% Start Condition Loop %%%%%%%%%%%%%%%%

% Initial Conditions
DesiredPos = str2num(input_Pos);
CurrentPos = 0;
Error = DesiredPos - CurrentPos;
n = 1;

while Error >= 0.1


    CurrentPos = OptiTrak_Data();
    Error = DesiredPos - CurrentPos; %Recheck error
    fprintf('\n The error at step %d is %s',n,Error)

    C887.MOV(input_axis,0.1 * n)
    n = n + 1;

end





function [rigidBody_Pos] = OptiTrak_Data()

data = natnetclient.getFrame;

rigidBodyX= data.RigidBodies.x * 1000;
rigidBodyY= data.RigidBodies.y * 1000;
rigidBodyZ= data.RigidBodies.z * 1000;


switch input_axis

    case 'X'
        rigidBody_Pos = rigidBodyX;
    case 'Y'
        rigidBody_Pos = rigidBodyY;
    case 'Z'
        rigidBody_Pos = rigidBodyZ;

end

end



%% matt
errorMovement('X', 12, C887)

function errorMovement(axis, pos, C887)
    while abs(pos - C887.qPOS(axis)) > 0.1
        currentError = errorEval(axis, pos, C887);
        if abs(currentError) > 0.1
            movement(axis, currentError, C887, pos)
        end
        disp(C887.qPOS('X'))
    end
end

function movement(axis, error, C887, pos)
    currentPosition = C887.qPOS('X');
    if pos > currentPosition
        newPosition = currentPosition + error/2;
    elseif pos < currentPosition
        newPosition = currentPosition - abs(error)/2;
    end
    C887.MOV(axis, newPosition)
end

function error = errorEval(axis, pos, C887)
    actualPosition = C887.qPOS(axis);
    error = abs(pos - actualPosition);
end