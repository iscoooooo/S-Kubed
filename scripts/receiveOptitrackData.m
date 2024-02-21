%------------------------MATLAB Function Info------------------------------
 % Written by: Francisco Sanudo
 % Date: 2/10/2024
 % 
 % PURPOSE
 % This function communicates with the OptiTrack system using the NatNet 
 % SDK to retrieve and store OptiTrack data. The loop to receieve and store 
 % data should be modified  to achieve the desired output and target file 
 % location
 %
 % INPUTS
 % - (none, for now)
 %
 % OUTPUTS
 % - markerData : a 3D matrix where each row corresponds to a frame, each 
 %                column corresponds to a marker, and the three dimensions
 %                represent the x, y, and z positions of each marker.
 %
 % NOTES
 % - Documentation states that the size and structure of the 'markerData'
 % variable can be adjusted based on our specific needs.
 %
 % - Additional variables can be added to store other types of data (e.g.,
 %   Rigid Body data) 
 %  
 % - We will need to customize the code based on the specific data that we
 %   want to capture and the structure of the data. (Teamm discussion)
 % 
 % - Will need to refer to the NatNET SDK documentation for more detailed
 %   info or available functions or data types.
 %
 % - Update the local and server IP addresses as necesarry.

 % Need to set the IP address of Motive Computer in SmallSat lab

function markerData = receiveOptiTrackData()
    % Create NatNet client
    client = NatNetML.NatNetClientML;

	% connect the client to the server 
	fprintf( 'Connecting to the server\n' )

    % Set the server IP address and port
    serverIP = '127.0.0.1';           % Use the IP address of  Motive computer
    serverPort = 1510;       % Use the port number configured in Motive
    client.Initialize(serverIP, serverPort);

    % Enable marker data (may need to adjust)
    client.EnableMarkerData();

    % Set the number of frames to capture
    numFramesToCapture = 100;  % variable, could ajust as needed

    % Initialize variables to store data
    markerData = zeros(numFramesToCapture, numMarkers, 3);  % Assuming 3D marker positions
    % Add additional variables as needed

    % Loop to capture data
    for frameIdx = 1:numFramesToCapture
        % Get the current frame of data
        frameOfData = client.GetLastFrameOfData();

        % Extract marker data
        markerPositions = frameOfData.LabeledMarkerPositions;
        markerData(frameIdx, :, :) = markerPositions(:, 1:3);

        % Add additional processing as needed (none as of now)

        % Add a delay to control the loop rate
        pause(0.01);
    end

    % Close the connection
    client.Uninitialize();

    % Save the data to a file (may need to adjust.. explore csv output)
    save('optitrack_data.mat', 'markerData');  % Save markerData to a .mat file
end
