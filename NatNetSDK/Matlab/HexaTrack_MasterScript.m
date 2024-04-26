
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                                S-Kubed 2024                             %
%                                                                         %
%           Main Script that Integrates Hexapod & OptiTrack Sensors,      %
%           & performs a basic perturbation-correction experiment.        %
%                                                                         %
%                   Written by Andre Turpin & Matt Portugal               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%% Documentation %%%%%%%%%%%%%%%%%%%%%%%%%%  %%
%                                                                         %
%                              File Dependencies:                         %
%                                                                         %
%           "Rotational_Motion.m" ; "Translational_Motion.m" ;            %
%   "HexaTrack_GUI.mlapp" ; "OptiTrak_Data.m" ; "Connection2Hexapod.m" ;  % 
%                           "natnet.m" ; "quaternion.m" ; "               %
%                                                                         %
%                            MATLAB Version: R2023b                       %
%           *This script depends on the installation for MATLAB drivers   %
%           of Physik Instrumente's proprietary software, MikroMove,      %
%             which communicates to the Hexapod in the GSC Language.      %
%                                                                         %
%                Additionally, the Motive motion-tracking software        %
%                uses a data-streaming server, "NatNet" which is          %
%        required to be setup via an SDK prior to running this program.   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%  Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%  %%

clc; close all; clearvars -except C887 Controller devicesTcpIp ip matlabDriverPath port stageType use_TCPIP_Connection

%%%%%%%%%%%%%%%%%%%% User Defines Hexapod Motion Type %%%%%%%%%%%%%%%%%%%%%

chosenDynamics = input('Choose Motion Type: Rotational or Translational? [ROT / TRA] \n \n >> ',"s");

%%%%%%%%%%%%%%%%%%%%%%%% Rotational Hexapod Motion %%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(chosenDynamics,'ROT') == true
    run("Rotational_Motion.m")

%%%%%%%%%%%%%%%%%%%%%% Translational Hexapod Motion %%%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(chosenDynamics,'TRA') == true
    run("Translational_Motion.m")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
    disp('Selection unknown...')
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

