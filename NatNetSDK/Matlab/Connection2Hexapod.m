% Connecting to Hexapod thru MATLAB Driver

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
    Check = true;
end
if(~isa(Controller,'PI_GCS_Controller'))
    Controller = PI_GCS_Controller();
end

if Check == true
    devicesTcpIp = Controller.EnumerateTCPIPDevices();
    disp(devicesTcpIp) 
    stageType = 'C-887.52';
    use_TCPIP_Connection = true;
    port = 50000;
    ip = '169.254.7.214';
    C887 = Controller.ConnectTCPIP(ip, port);
    C887.qIDN()
    C887 = C887.InitializeController();
end

disp('Controller Connected')
