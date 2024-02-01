%  Converts an incoming quaternion set q to a corresponding rotation 
%  matrix R.

%  q(4,1)   components, basis [1; i; j; k]: q(1) + i*q(2) + j*q(3) + k*q(4)
%           governing equation, i*i = j*j = k*k = -1
%           identities, i*j = k, j*i = -k, j*k = i, k*j = -i, k*i =j , i*k = -j, 

function R = quat2rot(q)
    q = q/norm(q); % normalize quaternion

    if (norm(q) - 1 > 1e-6) || (norm(q) - 1 < -1e-6)
        fprintf('Quaternion set does not satisfy unity constraint.\n')
    end

    eta = q(1);               % scalar part
    eps = [q(2); q(3); q(4)]; % vector part
    I   = eye(length(eps));   % identity matrix

    % Rotation matrix in terms of quaternion set, eq. 1.33 [ADR]
    R = (2*eta^2 - 1)*I + 2*eps*(eps') - 2*eta*skew(eps);
end