
%% 
clc; clear; close all;

app = HexaTrack_GUI;
pause(2)

yData = [ 2 5 9 0 1 6 3];
xData = [0 1 2 3 4 5 6];

% Code inside a callback or a function
axesHandle = app.UIAxes; % app.UIAxes is the name of your axes component
plot(axesHandle, xData, yData); % xData and yData are your data
title(axesHandle, 'My Plot Title');
xlabel(axesHandle, 'X-axis Label');
ylabel(axesHandle, 'Y-axis Label');

% Assuming app.UIAxes and app.UIImage are added to app.UIFigure directly

% Order components to have UIAxes on top
orderedChildren = setdiff(app.UIFigure.Children, [app.UIAxes, app.Image], 'stable');  % keep existing order but remove UIAxes and UIImage
orderedChildren = [orderedChildren; app.Image; app.UIAxes];  % add UIImage first, then UIAxes on top

% Apply the new order
app.UIFigure.Children = orderedChildren;
