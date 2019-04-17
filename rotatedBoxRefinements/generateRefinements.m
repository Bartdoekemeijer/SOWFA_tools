%% This function can generate the box refinements for SOWFA simulations
% Script by Bart Doekemeijer, April 17th 2019
%
% Description: This function will generate a number of refinement files: one 
% for each box around each turbine, with the desired dimensions, centered 
% around the turbine hubs.

outputDir = '.'; % export to current directory
HH = 119.0; % Turbine hub height
D = 178.3; % Turbine rotor diameter

domainDimensions = [3e3 3e3 1e3]; % Domain dimensions (necessary for mesh size calculations)
initialCells = [300 300 100]; % Domain discretization (necessary for mesh size calculations)

% Turbine locations (x,y)
turbLocations = [608.5  1232.55; 
                 608.5  1767.45;
                 1500.0 1232.55;
                 1500.0 1767.45;
                 2391.5 1232.55;
                 2391.5 1767.45];

% Box dimensions (for with nr. rows being the nr of refinements per turb)
boxDimensions = [D*3    D*3     300];
                %D*5    D*5     350;
                % ... ];

                
% ---------------------
% Mesh properties
InitialMeshSize = initialCells(1)*initialCells(2)*initialCells(3)
[X,Y,Z] = ndgrid(linspace(0,domainDimensions(1),initialCells(1)),...
                 linspace(0,domainDimensions(2),initialCells(2)),...
                 linspace(0,domainDimensions(3),initialCells(3)));
griddedMesh = ones(size(X));

% Loop
ii = 0;
for turbi = 1:size(turbLocations,1)
    for boxi = 1:size(boxDimensions,1)
        % Refine hypothetical mesh
        relvIndcs = X >= turbLocations(turbi,1)-boxDimensions(boxi,1)/2 & ...
                    X <= turbLocations(turbi,1)+boxDimensions(boxi,1)/2 & ...
                    Y >= turbLocations(turbi,2)-boxDimensions(boxi,2)/2 & ...
                    Y <= turbLocations(turbi,2)+boxDimensions(boxi,2)/2 & ...
                    Z <= boxDimensions(boxi,3);
        griddedMesh(relvIndcs) = 8*griddedMesh(relvIndcs);
        
        % Write new file
        ii = ii + 1;
        fileID = fopen(['topoSetDict.local.' num2str(ii)],'w');
        fprintf(fileID,'/*--------------------------------*- C++ -*----------------------------------*\\\n');
        fprintf(fileID,'| =========                 |                                                 |\n');
        fprintf(fileID,'| \\\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |\n');
        fprintf(fileID,'|  \\\\    /   O peration     | Version:  2.0                                   |\n');
        fprintf(fileID,'|   \\\\  /    A nd           | Web:      http://www.OpenFOAM.org               |\n');
        fprintf(fileID,'|    \\\\/     M anipulation  |                                                 |\n');
        fprintf(fileID,'\\*---------------------------------------------------------------------------*/\n');
        fprintf(fileID,'FoamFile\n');
        fprintf(fileID,'{\n');
        fprintf(fileID,'    version     2.0;\n');
        fprintf(fileID,'    format      ascii;\n');
        fprintf(fileID,'    class       dictionary;\n');
        fprintf(fileID,'    location    "system";\n');
        fprintf(fileID,'    object      topoSetDict.local.1;\n');
        fprintf(fileID,'}\n');
        fprintf(fileID,'// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //\n');
        fprintf(fileID,' \n');
        fprintf(fileID,'actions\n');
        fprintf(fileID,'(\n');
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name         local;\n');
        fprintf(fileID,'        type         cellSet;\n');
        fprintf(fileID,'        action       new;\n');
        fprintf(fileID,'        source       rotatedBoxToCell;\n');
        fprintf(fileID,'        sourceInfo\n');
        fprintf(fileID,'        {\n');
        fprintf(fileID,['            origin (     ' n2s(turbLocations(turbi,1)-boxDimensions(boxi,1)/2) ' ' n2s(turbLocations(turbi,2)-boxDimensions(boxi,2)/2) ' 0.0     );\n']);
        fprintf(fileID,['            i      (     ' n2s(boxDimensions(boxi,1)) ' 0.0      0.0     );\n']);
        fprintf(fileID,['            j      (     0.0      ' n2s(boxDimensions(boxi,2)) ' 0.0     );\n']);
        fprintf(fileID,['            k      (     0.0      0.0      ' n2s(boxDimensions(boxi,3)) ');\n']);
        fprintf(fileID,'        }\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,' \n');
        fprintf(fileID,');\n');
        fprintf(fileID,' \n');
        fprintf(fileID,'// ************************************************************************* //\n');
        fclose(fileID);
    end
end

% Final mesh
estimatedMeshSize = sum(griddedMesh(:))

% Locations of refinements
clf; plotRefinements(outputDir);
hold all
[x,y,z] = sphere;
for turbi = 1:size(turbLocations,1)
    plot3(turbLocations(turbi,1)*[1 1],turbLocations(turbi,2)*[1 1],[0 HH],'k','lineWidth',5);
    surf(0.5*D*x+turbLocations(turbi,1),0.5*D*y+turbLocations(turbi,2),0.5*D*z+HH);
end
colormap(bone)
xlim([0 domainDimensions(1)])
ylim([0 domainDimensions(2)])
% zlim([0 domainDimensions(3)])

function strOut = n2s(value)
    entryLength = 8;
    strOut = num2str(value,'%.1f');
    strOut = [strOut char(repmat(' ',1,entryLength-length(strOut)))];
end