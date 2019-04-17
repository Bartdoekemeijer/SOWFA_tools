function [] = plotRefinements(systemdir,dictPrefix)
% Function by Bart Doekemeijer, April 17th 2019
%
% Description: this function plots the rotatedBoxRefinements for a set of
% topoSetDict.local.* files. Simply specify the folder (typically your
% 'system' folder from SOWFA, and potentially a 'dictPrefix' (if it is
% different from "topoSetDict.local.*"), and run the code.
%
    if nargin < 1
        systemdir = '.';
    end
    if nargin < 2
        dictPrefix = 'topoSetDict.local*';
    end

    % Load all files and plot each refinement as a box
    dictFiles = dir([systemdir filesep dictPrefix]);
    if length(dictFiles) < 1
        error('No files found in your specified directory.')
    end
    for i = 1:length(dictFiles)
        filename = [dictFiles(i).folder filesep dictFiles(i).name];
        output(i) = importLocalDict(filename);
        boxCoords{i} = plotRotatedBox(output(i).origin,output(i).i,output(i).j,output(i).k);
        hold on;
    end

    grid on; axis equal;
    xlabel('x (m)')
    ylabel('y (m)')
    zlabel('z (m)')

    % Figure buttons
    c0 = uicontrol;
    c0.String='3D view';
    c0.Callback = @show3DView;
    c0.Position(2) = c0.Position(2) + 50;
    c1 = uicontrol;
    c1.String='Top view';
    c1.Callback = @showTopView;
    c1.Position(2) = c1.Position(2) + 25;
    c2 = uicontrol;
    c2.String='Side view';
    c2.Callback = @showSideView;

    function show3DView(src,event)
        view(-22.2000, 26.4400);
    end
    function showTopView(src,event)
        view(0,90);
    end
    function showSideView(src,event)
        view(0,0);
    end

    % Subfunction for loading localDict files
    function [output] = importLocalDict(file)
        file = fopen(file,'r');
        while (~feof(file))
            inputText = textscan(file,'%s',1,'delimiter','\n');
            inputText = strtrim(cell2mat(inputText{1}));
            if length(inputText) >= 6
                if strcmp(inputText(1:6),'origin') || strcmp(inputText(1:2),'i ') || strcmp(inputText(1:2),'j ') || strcmp(inputText(1:2),'k ')
                    charsToRemove = {'origin','i','j','k','(',')',';'};
                    tmpText = inputText;
                    for i = 1:length(charsToRemove)
                        tmpText = strrep(tmpText,charsToRemove{i},'');
                    end
                    if strcmp(inputText(1:6),'origin')
                        output.origin = str2num(tmpText);
                    else
                        output.(inputText(1)) = str2num(tmpText);
                    end
                end
            end
        end
        fclose(file);
    end

    % Plot function
    function [boxPoints] = plotRotatedBox(origin,i,j,k)
        if nargin < 4
            error('Wrong number of inputs specified.')
        end

        boxPoints(1,:) = origin;
        boxPoints(2,:) = origin + i;
        boxPoints(3,:) = origin + j;
        boxPoints(4,:) = origin + k;
        boxPoints(5,:) = origin + i + j;
        boxPoints(6,:) = origin + i + k;
        boxPoints(7,:) = origin + j + k;
        boxPoints(8,:) = origin + i + j + k;

        allCombVec = reshape(combnk(1:8,2)',[],1);
        plot3(boxPoints(allCombVec,1),boxPoints(allCombVec,2),boxPoints(allCombVec,3),'-');
    end
end