
if exist('C887','var') % Try using 'var'
    disp('The hexapod is connected.');
else
    disp('The hexapod is not connected');
%     run("Connection2Hexapod.m");
%     disp('Initializing connection to Hexapod')
end
