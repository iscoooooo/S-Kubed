clc; clear; close all;

% Set up figure
figure(1)
grid on; % Turn on the grid
ylabel('Random Value');
xlabel('Time (seconds)');
xlim([0, 200]); % Set this to the upper bound of your expected elapsed time
ylim([0, 10]);

% Initialize vectors to store elapsed time and random values
timeVector = [];
yVal = [];

% Start time measurement
startTime = tic;

% Run this for 200 seconds
for i = 1:200
    % Calculate elapsed time in seconds
    elapsedTime = toc(startTime);
    
    % Append the new elapsed time to the vector
    timeVector(end + 1) = elapsedTime;
    
    % Generate a random integer value between 1 and 10
    yVal(end + 1) = randi(10);

    % Update the plot
    if i == 1
        % Initialize the plot with the first point
        hPlot = plot(timeVector, yVal, 'b-o');
    else
        % Update the plot with the new data
        set(hPlot, 'XData', timeVector, 'YData', yVal);
    end

    % Update the graph
    drawnow;

    % Pause for 1 second
    pause(1);
end
