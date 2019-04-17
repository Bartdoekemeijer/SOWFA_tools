function h = plotTurbine3D(azimuthAngle,x_rotor,y_rotor,z_rotor)
if nargin <= 0
    azimuthAngle = 0;
end
if nargin <= 3
    x_rotor = 100;
    y_rotor = 200;
    z_rotor = 90; 
end

% Rotor dimensions
r_rotor = 60;

% Nacelle dimensions
dxNac = 12;
dyNac = 12;
dzNac = 4;

radius_tower = 5;
    
h = gcf; hold on;

if length(findobj('Tag','blade'))==0
    % Plot tower
    [X,Y,Z] = cylinder(radius_tower);
    Z = Z*(z_rotor-dzNac/2);
    X = X+x_rotor-dxNac/2;
    Y = Y+y_rotor;
    surf(X,Y,Z);
    hold on;

    % Plot nacelle
    cNac = [150]; % Color of nacelle
    patch(x_rotor+[-1 -1 0 0]*dxNac,y_rotor+[-1 +1 +1 -1]*dyNac/2,(z_rotor-dzNac/2)*ones(1,4),cNac); % Bottom patch
    patch(x_rotor+[-1 -1 0 0]*dxNac,y_rotor+[-1 +1 +1 -1]*dyNac/2,(z_rotor+dzNac/2)*ones(1,4),cNac); % Top patch
    patch(x_rotor*ones(1,4)-dxNac,y_rotor+[-1 -1 +1 +1]*dyNac/2,z_rotor+[-1 1 1 -1]*dzNac/2,cNac); % Back patch
    patch(x_rotor*ones(1,4),y_rotor+[-1 -1 +1 +1]*dyNac/2,z_rotor+[-1 1 1 -1]*dzNac/2,cNac); % Front patch
    patch(x_rotor+[-1 -1 0 0]*dxNac,y_rotor*ones(1,4)-dyNac/2,z_rotor+[-1 1 1 -1]*dzNac/2,cNac); % Side patch
    patch(x_rotor+[-1 -1 0 0]*dxNac,y_rotor*ones(1,4)+dyNac/2,z_rotor+[-1 1 1 -1]*dzNac/2,cNac); % Side patch

    % Plot rotor circle
    theta=-pi:0.01:pi;
    x_circ=r_rotor*cos(theta);
    z_circ=r_rotor*sin(theta);
    plot3(zeros(1,numel(x_circ))+x_rotor(1),x_circ+y_rotor(1),z_circ+z_rotor,'k--')
    grid on
    %axis equal
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');
    zlim([0 z_rotor+r_rotor])
else
    % No need to replot everything, simply:
    delete(findobj('Tag','blade')); % Delete blade objects
end
% Plot rotor blades
nBlades = 3;
nInterp = 20;

bladeAngles = linspace(azimuthAngle,azimuthAngle+360,nBlades+1);
bladeAngles = bladeAngles(1:end-1); % remove last entry

for j = 1:length(bladeAngles)
    y_blade = y_rotor+linspace(0,sind(bladeAngles(j))*r_rotor,nInterp);
    z_blade = z_rotor+linspace(0,cosd(bladeAngles(j))*r_rotor,nInterp);
    plot3(x_rotor*ones(nInterp),y_blade,z_blade,'k.','markerSize',10,'Tag','blade'); hold on
    %axis equal
end