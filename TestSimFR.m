
%% Connecting to Hexapod thru MATLAB Driver

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

%% Hexapod Movement Function

hexsim(C887, false, 1, 1, false, true)

function hexsim(C887, simulationBool, iterations, centerBool, movement)
    
    % Defining Axes
    x = 'X'; y = 'Y'; z = 'Z';
    u = 'U'; v = 'V'; w = 'W';

    % Moving Hexapod to Center Position
    if centerBool == true
        C887.FRF(x);
        pause(10);
    end

    % Simulation
    if simulationBool == true
        N = 30;                         % Number of points
        angleR = 13;                    % Angular Radius (< 14(max))
        transR = 35;                    % Translational Radius (< 42(max))
        randR = 20;
        theta = linspace(0, 2*pi, N);
        xvalAngle = angleR*cos(theta); yvalAngle = angleR*sin(theta);
        xvalTrans = transR*cos(theta); yvalTrans = transR*sin(theta);
        xvalRandR = randR*cos(theta); yvalRandR = randR*sin(theta);

        for i = 1:iterations
            disp('Rotational Motion (U and V axes)')
            for i = 1:iterations*5
                for i = 1:length(xvalAngle)
                    C887.MOV(u, xvalAngle(i));
                    C887.MOV(v, yvalAngle(i));
                    pause(0.12)
                end
            end
            pause(1)
            C887.MOV(u, 0);
            C887.MOV(v, 0);
            pause(1);
            disp('Translational Motion (X and Y axes)')
            for i = 1:iterations*5
                for i = 1:length(xvalTrans)
                    C887.MOV(x, xvalTrans(i));
                    C887.MOV(y, yvalTrans(i));
                    pause(0.12)
                end
            end
            pause(1)
            C887.MOV(x, 0);
            C887.MOV(y, 0);
            pause(1)
            disp('Translation and Rotational (Z and W axes)')
            for i = 1:iterations*5
                for i = 1:length(xvalRandR)
                    C887.MOV(x, xvalRandR(i));
                    C887.MOV(y, yvalRandR(i));
                    pause(0.12)
                end
            end
            pause(1)
            C887.MOV(x, 0);
            C887.MOV(y, 0);
            pause(1)
        end
    end
while true
    if movement == true
        axes = sort(input('Enter Axes of Movement (All uppercase, no spaces): ', 's'));
        if length(axes) < 4
            maxAxes = maximumMovements(axes);
        end
        message = sprintf('Maximum movement in any axis is %d\n', maxAxes);
        disp(message)
        for i = 1:length(axes)
            prompt = sprintf('Enter movement(mm) for %s-axis: ', axes(i));
            while true
                axisInput = input(prompt);
                if axisInput >= -maxAxes && axisInput <= maxAxes
                    movements(i) = axisInput;
                    break;
                else
                    disp('Invalid: Out of Range. Retry!')
                end
            end
        end
        for i = 1:length(axes)
            messageOverview = [axes(i), ': ', num2str(movements(i)), ' mm'];
            disp(messageOverview)
        end
        if length(axes) == 4
            C887.MOV(axes(1), movements(1));
            C887.MOV(axes(2), movements(2));
            C887.MOV(axes(3), movements(3));
            C887.MOV(axes(4), movements(4));
        elseif length(axes) == 3
            C887.MOV(axes(1), movements(1));
            C887.MOV(axes(2), movements(2));
            C887.MOV(axes(3), movements(3));
        elseif length(axes) == 2
            C887.MOV(axes(1), movements(1));
            C887.MOV(axes(2), movements(2));
        elseif length(axes) == 1
            C887.MOV(axes(1), movements(1));
        end
        pause(3)
        if length(axes) == 4
            C887.MOV(axes(1), 0);
            C887.MOV(axes(2), 0);
            C887.MOV(axes(3), 0);
            C887.MOV(axes(4), 0);
        elseif length(axes) == 3
            C887.MOV(axes(1), 0);
            C887.MOV(axes(2), 0);
            C887.MOV(axes(3), 0);
        elseif length(axes) == 2
            C887.MOV(axes(1), 0);
            C887.MOV(axes(2), 0);
        elseif length(axes) == 1
            C887.MOV(axes(1), 0);
        end
        pause(3)
    end
end
    
    function max = maximumMovements(axes)
    % 3 Axes of Movement describe maximum millimeters of movement in any
    % axis direction. Ex. 'XYZ': Output: 20 mm (20 mm x, 20 mm y, 20 mm z)
    if length(axes) == 5
        axesToMaxMap = containers.Map({'UVWXY', 'UVWXZ', 'UVWYZ', 'UVXYZ',...
            'UWXYZ', 'VWXYZ'}, ...
            [1, 1, 1, 1, 1, 1]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end

    if length(axes) == 4
        axesToMaxMap = containers.Map( {'UVWX', 'UVWY', 'UVWZ', 'UVXY', 'UVXZ',...
            'UVYZ', 'UWXY', 'UWXZ', 'UWYZ', 'VWXY', 'VWXZ', 'VWYZ', 'UXYZ', 'VXYZ',...
            'WXYZ'},...
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...
            1, 1, 1, 1, 1]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end

    if length(axes) == 3
        axesToMaxMap = containers.Map( {'UVW', 'UVX', 'UVY', 'UVZ', 'UWX',...
            'UWY', 'UWZ', 'UXY', 'UXZ', 'UYZ', 'VWX', 'VWY', 'VWZ', 'VXY',...
            'VXZ', 'VYZ', 'WXY', 'WXZ', 'WYZ', 'XYZ'},...
            [8, 8, 9, 7, 14, 10, 7, 14, 9, 9, ...
            10, 12, 7, 13, 9, 7, 18, 11, 12, 17]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end

    if length(axes) == 2
        axesToMaxMap = containers.Map({'XY', 'XZ', 'UX', 'VX', 'WX',...
            'YZ', 'UY', 'VY', 'WY', 'UZ', 'VZ', 'WZ', 'UV', 'UW', 'VW'},...
            [40, 18, 12, 14, 21, 18, 14, 12, 13, 9, 9, 15, 10, 12, 11]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end

    if length(axes) == 1
        axesToMaxMap = containers.Map({'X', 'Y', 'Z', 'U', 'V', 'W'}, ...
            [50, 50, 25, 14, 14, 25]);
        if isKey(axesToMaxMap, axes)
            max = axesToMaxMap(axes);
        end
    end
    end
end










