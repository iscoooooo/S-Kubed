%% S-Kubed Data Comparison Intialization
% Last Revised: 3/26/24
% Andre Turpin

%%%%%%%%%%%%%%%%%%%%% App Initialization %%%%%%%%%%%%%%%%%%%%%
clc; clearvars -except C887 Controller devicesTcpIp ip matlabDriverPath port stageType use_TCPIP_Connection

app = MainApp;

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




%%%%%%%%%%%%%%%%%%%%% App Logic %%%%%%%%%%%%%%%%%%%%%
while isvalid(app)
    activeTabTitle = app.TabGroup.SelectedTab.Title;


    switch activeTabTitle

        case 'Hexapod (PI/GSC)'
            %Code to run when Tab 1 is selected


            disp('Tab 1 is active');
            pause (1)



        case 'Data Comparison'
            %Code to run when Tab 1 is selected


            disp('Tab 2 is active');
            pause (1)

            userInput = input('Do you want to proceed? (Y/N): ', 's'); % The 's' option treats the input as a string




            if userInput == 'Y'
                disp('Checking connection with Hexapod...');
                pause(1)
                run('Hexapod_Connection_Check.m')


                %%%%% Continue Code for Euler Angles %%%%%
                
            elseif userInput == 'N'

                disp('Ok, I will not start.....')
                return

            else
                disp('You did not enter Y or N')
                return

            end



    end %Current Tab loop end


end %Final end for While app is active loop












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extra Codes

% % To check Hexapod Centered:
% if all(C887.qPOS <= 0.2 & C887.qPOS >= -0.2)
%     disp('Hexapod is at the origin')
%     app.Lamp_2.Color = [0,1,0]; %Set lamp to green
% else
%     disp('Hexapod is not at the origin')
%     app.Lamp_2.Color = [1,0,0]; %Set lamp to red
% end
