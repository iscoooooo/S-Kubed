%% S-Kubed Hexapod Interfacing
% Last Revised: 4/14/24
% Andre Turpin


clc; clearvars -except C887 Controller devicesTcpIp ip matlabDriverPath port stageType use_TCPIP_Connection

app = MainApp

%Initialize and zero variables for App Input
switch_status = 'Off';
input_axes = 'init';
stop_button = 0;
button_status = false;
axis1_command = 0;
axis2_command = 0;
axis3_command = 0;
slider_max = 10;

pause(3) % Wait for app to load

%~~~~~~~~~~~~~~~~ Check & Connect to Hexapod ~~~~~~~~~~~~~~~~%
disp('Checking connection with Hexapod...');
pause(1)

if exist('C887','var') 
    disp('The hexapod is connected.');

    app.Lamp_3.Color = [0,1,0]; % Set lamp color to green
else

    disp('The hexapod is not connected');
    run("Connection2Hexapod.m");
    disp('Initializing connection to Hexapod...');
    pause(2)

    disp('Hexapod is now connected');
    app.Lamp_3.Color = [1,0,0];
end



%~~~~~~~~~~~~~~~~ Waiting for switch & input ~~~~~~~~~~~~~~~~%
while button_status ~= true

    disp('Waiting to Center Hexapod')
    pause(2)

end

if button_status == true
    disp('Centering Hexapod.....')
    C887.FRF('X');
    pause(9)
    disp('Aligned Hexapod')
end

while strcmp(switch_status, 'Off')

    fprintf('Waiting for switch to turn on... \n \n')
    pause(2)
end

while strcmp(input_axes, 'init')
    fprintf('Switch on. Waiting for axis input... \n \n')
    pause(2)
end



%~~~~~~~~~~~~~~~~ Begin Input_Axes Logic ~~~~~~~~~~~~~~~~%

old_axes = input_axes;

while strcmp(switch_status, 'On')

if all(C887.qPOS <= 0.2 & C887.qPOS >= -0.2)
    disp('Hexapod is at the origin')
    app.Lamp_2.Color = [0,1,0]; %Set lamp to green
else
    disp('Hexapod is not at the origin')
    app.Lamp_2.Color = [1,0,0]; %Set lamp to red
end




    input_axes = sort(input_axes);


    if length(input_axes) == 3
        sortedAxesKey = char(input_axes);
        axesToMaxMap = containers.Map( {'UVW', 'UVX', 'UVY', 'UVZ', 'UWX',...
            'UWY', 'UWZ', 'UXY', 'UXZ', 'UYZ', 'VWX', 'VWY', 'VWZ', 'VXY',...
            'VXZ', 'VYZ', 'WXY', 'WXZ', 'WYZ', 'XYZ'},...
            [8, 8, 9, 7, 14, 10, 7, 14, 9, 9, ...
            10, 12, 7, 13, 9, 7, 18, 11, 12, 17]);
        if isKey(axesToMaxMap, sortedAxesKey)
            slider_max = axesToMaxMap(sortedAxesKey);
        end
    end


    if length(input_axes) == 2
        sortedAxesKey = char(input_axes);
        axesToMaxMap = containers.Map({'XY', 'XZ', 'UX', 'VX', 'WX',...
            'YZ', 'UY', 'VY', 'WY', 'UZ', 'VZ', 'WZ', 'UV', 'UW', 'VW'},...
            [40, 18, 12, 14, 21, 18, 14, 12, 13, 9, 9, 15, 10, 12, 11]);
        if isKey(axesToMaxMap, sortedAxesKey)
            slider_max = axesToMaxMap(sortedAxesKey);
        end
    end


    if length(input_axes) == 1
        sortedAxesKey = char(input_axes);
        axesToMaxMap = containers.Map({'X', 'Y', 'Z', 'U', 'V', 'W'}, ...
            [50, 50, 25, 14, 14, 25]);
        if isKey(axesToMaxMap, sortedAxesKey)
            slider_max = axesToMaxMap(sortedAxesKey);
        end
    end


    app.updateData(slider_max);
    drawnow;


    %~~~~~~~~~~~~~~~~ Begin Hexapod Translation/Rotation ~~~~~~~~~~~~~~~~%



    if length(input_axes) == 1
        if input_axes ~= old_axes %New input detected
            pause(1)
            C887.MOV('X',0)
            C887.MOV('Y',0)
            C887.MOV('Z',0)

            C887.MOV('U',0)
            C887.MOV('V',0)
            C887.MOV('W',0)

            axis1_command = 0;
            axis2_command = 0;
            axis3_command = 0;

            app.Axis1Slider.Value = 0;
            app.Axis2Slider.Value = 0;
            app.Axis3Slider.Value = 0;

            app.Axis1EditField.Value = 0;
            app.Axis1EditField_2.Value = 0;
            app.Axis1EditField_3.Value = 0;

            old_axes = input_axes;

            pause(3)
        end

        C887.MOV(input_axes(1), axis1_command); % in millimeters
        %         fprintf('Axis 1 Translating to %0.4f \n \n', axis1_command)
        pause(1);

    elseif length(input_axes) == 2
        if input_axes ~= old_axes %New input detected
            pause(1)
            C887.MOV('X',0)
            C887.MOV('Y',0)
            C887.MOV('Z',0)

            C887.MOV('U',0)
            C887.MOV('V',0)
            C887.MOV('W',0)

            axis1_command = 0;
            axis2_command = 0;
            axis3_command = 0;

            app.Axis1Slider.Value = 0;
            app.Axis2Slider.Value = 0;
            app.Axis3Slider.Value = 0;

            app.Axis1EditField.Value = 0;
            app.Axis1EditField_2.Value = 0;
            app.Axis1EditField_3.Value = 0;

            old_axes = input_axes;

            pause(3)
        end
        C887.MOV(input_axes(1), axis1_command); % in millimeters
        %         fprintf('Axis 1 Translating to %0.4f \n \n', axis1_command)
        pause(1);

        C887.MOV(input_axes(2), axis2_command); % in millimeters
        %         fprintf('Axis 2 Translating to %0.4f \n \n', axis2_command)
        pause(1);

    elseif length(input_axes) == 3
        if input_axes ~= old_axes %New input detected
            pause(1)
            C887.MOV('X',0)
            C887.MOV('Y',0)
            C887.MOV('Z',0)

            C887.MOV('U',0)
            C887.MOV('V',0)
            C887.MOV('W',0)

            axis1_command = 0;
            axis2_command = 0;
            axis3_command = 0;

            app.Axis1Slider.Value = 0;
            app.Axis2Slider.Value = 0;
            app.Axis3Slider.Value = 0;

            app.Axis1EditField.Value = 0;
            app.Axis1EditField_2.Value = 0;
            app.Axis1EditField_3.Value = 0;

            old_axes = input_axes;

            pause(3)
        end

        C887.MOV(input_axes(1), axis1_command); % in millimeters
        %         fprintf('Axis 1 Translating to %0.4f \n \n', axis1_command)
        %         pause(1);

        C887.MOV(input_axes(2), axis2_command); % in millimeters
        %         fprintf('Axis 2 Translating to %0.4f \n \n', axis2_command)
        %         pause(1);

        C887.MOV(input_axes(3), axis3_command); % in millimeters
        %         fprintf('Axis 3 Translating to %0.4f \n \n', axis3_command)
        %         pause(1);
    end


end

%~~~~~~~~~~~~~~~~ For App Shutdown ~~~~~~~~~~~~~~~~%

while strcmp(switch_status, 'Off')'

    if stop_button == 1
        status = 000
        return
    end


end











