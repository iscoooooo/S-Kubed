function saveToCSV(csvFileName,frameData, timeData, rigidBodyNames, ...
    rigidBodyX, rigidBodyY, rigidBodyZ, ...
    rigidBodyRoll,rigidBodyPitch,rigidBodyYaw)
% Combine data into a table
%   Need to solve frame & time data inconsistency
dataTable = table(frameData', timeData', 'VariableNames', {'Frame', 'Time'});

for i = 1:numel(rigidBodyNames)
    dataTable.('rigidBody_X') = rigidBodyX(:, i);
    dataTable.('rigidBody_Y') = rigidBodyY(:, i);
    dataTable.('rigidBody_Z') = rigidBodyZ(:, i);
    dataTable.('rigidBody_Roll') = rigidBodyRoll(:, i);
    dataTable.('rigidBody_Pitch') = rigidBodyPitch(:, i);
    dataTable.('rigidBody_Yaw') = rigidBodyYaw(:, i);
end

% Write data to CSV file
writetable(dataTable, csvFileName,'WriteVariableNames',true);
fprintf('Data saved to %s\n', csvFileName);
end
