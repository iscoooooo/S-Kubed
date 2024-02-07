%   Converts an incoming rotation matrix R to corresponding yaw, pitch, and
%   roll angles. This assumes 3-2-1 (Z-Y-X) rotation sequence.

function [psi,theta,phi] = rot2euler(R)

%{
  Inputs:
  R         - rotation matrix
  
  Outputs:
  psi       - yaw angle
  theta     - pitch angle 
  phi       - roll angle

%}

% -----------------------------------------------------------------

% Singularity occurs when the Pitch angle is theta = +/- 90 deg.

if (R(1,1) || R(3,3)) == 0
    error('Singularity encountered.')
else
    psi = atan2d(R(1,2),R(1,1));
    theta = -asind(R(1,3));
    phi = atan2d(R(2,3),R(3,3));

if psi < 0
    psi = mod(psi+360,360);
end

end