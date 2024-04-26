function [rigidBody_Pos] = OptiTrak_Data(obj,input_axis) %Pulls current position of indicated axis from Motive

data = obj.getFrame;

rigidBodyX= data.RigidBodies(1).x * 1000;
rigidBodyY= data.RigidBodies(1).y * 1000;
rigidBodyZ= data.RigidBodies(1).z * 1000;

q = quaternion(data.RigidBodies(1).qw, data.RigidBodies(1).qx, ...
    data.RigidBodies(1).qy, data.RigidBodies(1).qz);

eulerAngles = q.EulerAngles('ZYX');

rigidBodyU = eulerAngles(3)* 180/pi;
rigidBodyV = eulerAngles(2)* 180/pi;
rigidBodyW = eulerAngles(1)* 180/pi;

switch input_axis

    case 'X'
        rigidBody_Pos = rigidBodyX;
    case 'Y'
        rigidBody_Pos = rigidBodyY;
    case 'Z'
        rigidBody_Pos = rigidBodyZ;
    case 'U'
        rigidBody_Pos = rigidBodyU;
    case 'V'
        rigidBody_Pos = rigidBodyV;
    case 'W'
        rigidBody_Pos = rigidBodyW;

end

end
