% MasterScript.m
try
    % Start MATLAB parallel pool
    pool = gcp('nocreate');
    if isempty(pool)
        pool = parpool; 
    end

    % Define tasks
    hexapodTask = @() run('TestSimFR.m');
    optitrackTask = @() run('MAIN.m'); 

    % Start tasks in parallel
    fHexapod = parfeval(pool, hexapodTask, 0); 
    fOptitrack = parfeval(pool, optitrackTask, 0); 

    % Wait for tasks to complete 
    wait(fHexapod);
    wait(fOptitrack);

catch ME
    disp('Error running parallel tasks:');
    disp(ME.message);
end