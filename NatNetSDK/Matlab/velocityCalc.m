function [vTotal] = velocityCalc(ax1, ax2, ax3, time)

dx = diff(ax1);
dy = diff(ax2);
dz = diff(ax3);

dt = diff(time);

vx = dx ./ dt;
vy = dy ./ dt;
vz = dz ./ dt;

vTotal = sqrt(vx.^2 + vy.^2 + vz.^2);

end