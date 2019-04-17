clear all; close all; clc;

h=plotTurbine3D(0);
set(gca,'View',[137.220 19.7600]);
for azimuthAngle = 0:1:120 % 10 cycles
    tic
    h=plotTurbine3D(azimuthAngle,h);
    axis equal tight
    drawnow()
    if ishandle(h) == false; break; end;
end