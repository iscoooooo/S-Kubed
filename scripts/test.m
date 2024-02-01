% This is a test script that extracts rigid body data from a csv output
% file from Motive and plots the cartesian coordinates over time, and
% shows an animation of the attitude variation over time.

clc;clear;close all

%% EDIT %%
fileName = 'test.csv'; % specify file name & extension from the data folder

%% DO NOT EDIT %%

fprintf('Choose from the following cases: \n\n')
fprintf('\t [1] Position vs. Time\n')
fprintf('\t [2] Euler Angles vs. Time\n')
fprintf('\t [3] Attitude vs. Time\n\n')
n = input('Selection: ');
fprintf('\n')

if ~isnumeric(n)
    error("Input must be a numeric value between 1-3, and not a %s",class(n))
elseif (n < 1 || n > 3)
    error("Input must be a numeric value between 1-3.")
end

% Get file from the data folder path
filespec = "../data/" +  fileName;

% Extract quaternions and cartesian coords at each sample frame/time
[frame,time,quat,pos] = statereader(filespec);

%% Quaternions ---> Euler Angles
N = size(quat,1);

% initialize arrays
psi = zeros(N,1); theta = zeros(N,1); phi = zeros(N,1);

for ii = 1:N
    R = quat2rot(quat(ii,:));                   % Rotation matrix
    [psi(ii),theta(ii),phi(ii)] = rot2euler(R); % Euler angles
end

%% Plotting

% Figure properties
set(gcf,'units','normalized','position', [0, 0, .5, .5],...
    'DefaultTextInterpreter','Latex');
movegui(gcf,'center')

switch n
    case 1
        % Plot Cartesian coords
        title('Position vs. time','FontSize',18)
        xlabel('mm','FontSize',14), ylabel('mm','FontSize',15)
        zlabel('mm','FontSize',14)
        curve = animatedline('Linewidth',2);
        hold on, grid on

        % Update limits to match tracking volume
        %   These will change based on setup and definition of the 
        %   ground plane in tracking software.
        xlim([min(pos(:,1)), max(pos(:,1))])
        ylim([min(pos(:,2)), max(pos(:,2))])
        zlim([min(pos(:,3)), max(pos(:,3))])

        view([-37.5,30])
        
        % Draw and label the X, Y and Z axes
        scatter3(0,0,0,'ko','filled')
        mArrow3([0 0 0],[1*100 0 0],'color','red','stemWidth',2,'facealpha',0.5);
        mArrow3([0 0 0],[0 1*100 0],'color','green','stemWidth',2,'facealpha',0.5);
        mArrow3([0 0 0],[0 0 1*100],'color','blue','stemWidth',2,'facealpha',0.5);
        % axis equal
        light

        % Start animation
        for ii = 1:length(pos(:,1))
            addpoints(curve,pos(ii,1),pos(ii,2),pos(ii,3))
            head = scatter3(pos(ii,1),pos(ii,2),pos(ii,3),'r','filled');
            drawnow
            pause(1/N)
            delete(head)
        end
    case 2
        % Plot Euler angles vs. time
        hold on
        plot(time,phi,'LineWidth',2)
        plot(time,theta,'LineWidth',2)
        plot(time,psi,'LineWidth',2)
        hold off
        title('Euler angles vs. time','FontSize',18)
        xlabel('Time (s)','FontSize',18)
        lgd = legend('\phi','\theta','\psi');
        fontsize(lgd,14,'points')
        grid on
    case 3
        % Visualize quaternions
        for ii = 1:length(quat)
            q = quaternion(quat(ii,1),quat(ii,2),quat(ii,3),quat(ii,4));
            fig = poseplot(q);
            title('Attitude Visualization','FontSize',18)
            pause(1/N)
            delete(fig)
        end
end