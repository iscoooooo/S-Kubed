%%Import Calibration file (CAL) into Simulink Hub

calFileName = 'project.ttp'; %% change the file name here
fileload = TT_LoadCalibration(calFileName);

if fileload == NPRESULT_SUCCESS
    fprintf('%s successfully loaded.\n', calFileName);
else
    fprintf('Error: %s\n', TT_GetResultString(fileload));
end