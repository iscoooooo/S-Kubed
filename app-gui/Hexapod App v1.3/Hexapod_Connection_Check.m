if exist('C887','var')
    disp('The hexapod is connected.');

    app.Lamp_5.Color = [0,1,0]; % Set lamp color to green
else

    disp('The hexapod is not connected');
    run("Connection2Hexapod.m");
    disp('Initializing connection to Hexapod...');
    pause(2)

    disp('Hexapod is now connected');
    app.Lamp_5.Color = [1,0,0];
end
