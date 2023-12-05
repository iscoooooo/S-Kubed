function [frame,time,quat,pos] = statereader(filespec)
% This function assumes that the loaded data is in comma
% separated value (csv) text format

expr = 'Frame';  % text to look for in the file

% loop: to find where the data range is at
n = 0;  % line count
fid = fopen(filespec,'r'); % file to read in

while true
    dataline = fgetl(fid); % read in one line at a time

    n = n + 1; % find the line number

    if ischar(dataline)  % if the line is a character string
        % found the 1st string I am seeking
        if ~isempty(regexp(dataline,expr, 'once')) % check for match
            idx = n;
        end
    end

    % break loop if there are no longer any text
    if ~ischar(dataline)
        break;
    end
end

fclose(fid);

%% Extract arrays

% Create homegenous array from data file
T = readmatrix(filespec,'NumHeaderLines',idx,'Delimiter',',');

% Collect output
frame  = T(:,1);
time   = T(:,2);
quat   = T(:,3:6);
pos    = T(:,7:9);

end