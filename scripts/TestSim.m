
%hexsim(1,0.2,false,C887)

R = 14;
RR = 30;
N = 30;
theta = linspace(0, 2*pi, N);
xval = R*cos(theta);
yval = R*sin(theta);

xvalTrans = RR*cos(theta);
yvalTrans = RR*sin(theta);

x = 'X'; y = 'Y';
u = 'U'; v = 'V';

iterations = 3;

% for j = 1:iterations
%     for i = 1:length(xval)
%         C887.MOV(u, xval(i));
%         C887.MOV(v, yval(i));
%         pause(0.1)
%     end
% end

C887.MOV(u, 0);
C887.MOV(v, 0);

pause(5)

for j = 1:iterations
    for i = 1:length(xvalTrans)
        C887.MOV(x, xvalTrans(i));
        C887.MOV(y, yvalTrans(i));
        pause(0.15)
    end
end

C887.MOV(x, 0);
C887.MOV(y, 0);


function hexsim(iterations, time, connectLogical, C887)
    
% If connectLogical == true, initiates connection to hexapod
% If connectLogical == false, assumes connection is established
if connectLogical == true
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
        check = 1;
    end
    if(~isa(Controller,'PI_GCS_Controller'))
        Controller = PI_GCS_Controller();
    end
    
    assignin('base', 'Controller', Controller);
    assignin('base', 'matlabDriverPath', matlabDriverPath);

    if check == 1
        devicesTcpIp = Controller.EnumerateTCPIPDevices();
        disp(devicesTcpIp) % Displaying Hexapod Device
        stageType = 'C-887.52';
        use_TCPIP_Connection = true;
        port = 50000;
        ip = '169.254.7.214';
        C887 = Controller.ConnectTCPIP(ip, port);
        C887.qIDN()
        C887 = C887.InitializeController();
        ready = true;
    else
        disp('No controller connected')
    end
    assignin('base', 'C887', C887);
    assignin('base', 'ip', ip);
    assignin('base', 'stageType', stageType);
    assignin('base', 'devicesTcpIp', devicesTcpIp);
    assignin('base', 'port', port);
    assignin('base', 'use_TCPIP_Connection', use_TCPIP_Connection);
end

if connectLogical == false
    ready = true;
    disp('Already Connected to Hexapod')
end

if ready == true
    disp('Starting Simulation')
    pause(3);

    x = 'X'; y = 'Y'; z = 'Z';
    u = 'U'; v = 'V'; w = 'W';

    C887.FRF(x);
    disp('Centering Hexapod')
    pause(13);
    
    for i = 1:iterations
        disp('Moving')
        C887.MOV(u, -12); 
        pause(time);
%         C887.MOV(u, 0); 
        pause(time);
        C887.MOV(u, -8.5);
        C887.MOV(v, -8.5);
        pause(time*1.5);
%         C887.MOV(u, 0);
%         C887.MOV(v, 0);
        pause(time);
        C887.MOV(v, -12);
        pause(time);
%         C887.MOV(v, 0);
        pause(time);
        C887.MOV(u, 8.5);
        C887.MOV(v, -8.5);
        pause(time*1.5);
%         C887.MOV(u, 0);
%         C887.MOV(v, 0);
        pause(time);
        C887.MOV(u, 12);
        pause(time);
%         C887.MOV(u, 0);
        pause(time);
        C887.MOV(u, 8.5);
        C887.MOV(v, 8.5);
        pause(time*1.5);
%         C887.MOV(u, 0);
%         C887.MOV(v, 0);
        pause(time);
        C887.MOV(v, 12);
        pause(time);
%         C887.MOV(v, 0);
        pause(time);
        C887.MOV(u, -8.5);
        C887.MOV(v, 8.5);
        pause(time*1.5);
%         C887.MOV(u, 0);
%         C887.MOV(v, 0);
        pause(time);
        C887.MOV(u, -12);
        pause(time);
        C887.MOV(u, 0);
        C887.MOV(v, 0);

        pause(time*4);

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

        pause(time*4);

        C887.MOV(w, -25);
        pause(time);
        C887.MOV(w, 25);
        pause(time*2);
        C887.MOV(w, 0);
        pause(time);

        pause(time*4);

        C887.MOV(z, 25);
        pause(time);
        C887.MOV(z, -25);
        pause(time*2);
        C887.MOV(z, 0);
        pause(time);

        pause(time*4);

        C887.MOV(z, 10);
        C887.MOV(w, 10);
        pause(time);
        C887.MOV(w, -10);
        pause(time*2);
        C887.MOV(w, 0);
        C887.MOV(z, 0);
        pause(time);
        C887.MOV(z, -10);
        C887.MOV(w, 10);
        pause(time);
        C887.MOV(w, -10);
        pause(time*2);
        C887.MOV(w, 0);
        C887.MOV(z, 0);
    end
end
end