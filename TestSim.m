
%%% Connecting to Hexapod %%%

%% Loading MATLAB Driver

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
end
if(~isa(Controller,'PI_GCS_Controller'))
    Controller = PI_GCS_Controller();
end

%% Connection to Hexapod

devicesTcpIp = Controller.EnumerateTCPIPDevices();
disp(devicesTcpIp) % Displaying Hexapod Device

stageType = 'C-887.52';

use_TCPIP_Connection = true;
port = 50000;
ip = '169.254.7.214';

C887 = Controller.ConnectTCPIP(ip, port);

C887.qIDN()
C887 = C887.InitializeController();

%% Define Axes

x = 'X'; y = 'Y'; z = 'Z';
u = 'U'; v = 'V'; w = 'W';

%% Simulation

% hexsim(iterations, time between movements);
hexsim(1, 1);

%% Test Movements 

time = 1;

% z and w,v at the same time?

C887.MOV(z, 15);
C887.MOV(v, 10);
pause(time);
C887.MOV(z, -15);
C887.MOV(v, -10);
pause(time);
C887.MOV(z, 0);
C887.MOV(v, 0);
pause(time);
C887.MOV(z, 15);
C887.MOV(u, 10);
pause(time);
C887.MOV(z, -15);
C887.MOV(u, -10);
pause(time);
C887.MOV(z, 0);
C887.MOV(u, 0);
pause(time);

%% Simulation Function

function hexsim(iterations, time)
    
    x = 'X'; y = 'Y'; z = 'Z';
    u = 'U'; v = 'V'; w = 'W';

    C887.FRF(x);
    pause(7);

    for i = 1:iterations
        C887.MOV(u, -12); 
        pause(time);
        C887.MOV(u, 0); 
        pause(time);
        C887.MOV(u, -8.5);
        C887.MOV(v, -8.5);
        pause(time);
        C887.MOV(u, 0);
        C887.MOV(v, 0);
        pause(time);
        C887.MOV(v, -12);
        pause(time);
        C887.MOV(v, 0);
        pause(time);
        C887.MOV(u, 8.5);
        C887.MOV(v, -8.5);
        pause(time);
        C887.MOV(u, 0);
        C887.MOV(v, 0);
        pause(time);
        C887.MOV(u, 12);
        pause(time);
        C887.MOV(u, 0);
        pause(time);
        C887.MOV(u, 8.5);
        C887.MOV(v, 8.5);
        pause(time);
        C887.MOV(u, 0);
        C887.MOV(v, 0);
        pause(time);
        C887.MOV(v, 12);
        pause(time);
        C887.MOV(v, 0);
        pause(time);
        C887.MOV(u, -8.5);
        C887.MOV(v, 8.5);
        pause(time);
        C887.MOV(u, 0);
        C887.MOV(v, 0);
        pause(time);
        C887.MOV(u, -12);
        pause(time);
        C887.MOV(u, 0);

        pause(3);

        C887.MOV(x, -40);
        C887.MOV(y, 0);
        pause(time)
        C887.MOV(x, -40);
        C887.MOV(y, -40);
        pause(time)
        C887.MOV(x, 0);
        C887.MOV(y, -40);
        pause(time)
        C887.MOV(x, 40);
        C887.MOV(y, -40);
        pause(time)
        C887.MOV(x, 40);
        C887.MOV(y, 0);
        pause(time);
        C887.MOV(x, 40);
        C887.MOV(y, 40);
        pause(time)
        C887.MOV(x, 0);
        C887.MOV(y, 40);
        pause(time)
        C887.MOV(x, -40);
        C887.MOV(y, 40);
        pause(time)
        C887.MOV(x, -40);
        C887.MOV(y, 0);
        pause(time)
        C887.MOV(x, 0);
        C887.MOV(y, 0);

        pause(3);

        C887.MOV(w, -25);
        pause(time);
        C887.MOV(w, 25);
        pause(time*2);
        C887.MOV(w, 0);
        pause(time);

        pause(3);

        C887.MOV(z, 25);
        pause(time);
        C887.MOV(z, -25);
        pause(time*2);
        C887.MOV(z, 0);
        pause(time);

        pause(3);

        C887.MOV(z, 20);
        C887.MOV(w, 20);
        pause(time);
        C887.MOV(w, -20);
        pause(time*2);
        C887.MOV(w, 0);
        C887.MOV(z, 0);
        pause(time);
        C887.MOV(z, -20);
        C887.MOV(w, -20);
        pause(time);
        C887.MOV(w, 20);
        pause(time*2);
        C887.MOV(w, 0);
        C887.MOV(z, 0);
    end
end








