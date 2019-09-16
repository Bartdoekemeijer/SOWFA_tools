%% Convert a folder of instantaneous VTKs to MATLAB format

%% Setup
% source files
t_array = 20005:5:20020; % Time instances to convert
mainFolder = 'O:\RE19.6turb.varyingWsWd.mixedOLCL\sliceDataInstantaneous'; % Main folder

% Destination file
filenameMat = 'vtkInfo.mat';

%% Start conversion
% Determine which VTK files exist according to the first folder
vtkFilelist = dir([mainFolder filesep num2str(t_array(1)) filesep 'U_*'])

for fi = 1:length(vtkFilelist)
    currentFilename = vtkFilelist(fi).name;
    disp(['Processing files with name ''' currentFilename '''.'])
    saveData = struct('filename',currentFilename);
    for ti = 1:length(t_array)
        t = t_array(ti);
        currentFolder = [mainFolder filesep num2str(t) filesep];
        if ti == 1
            saveData.t = [t]; 
            tic();
            [~,saveData.cellCenters,saveData.cellData{ti}] = importVTK([currentFolder filesep currentFilename]);
        else
            disp(['  Processing time instant ' num2str(t) '. Prev iteration: ' num2str(toc) ' s.']); tic();
            [~,cellCentersTmp,saveData.cellData{ti}] = importVTK([currentFolder filesep currentFilename]);
            saveData.t = [saveData.t t];
            if max(max(abs(cellCentersTmp-saveData.cellCenters))) > 1e-6
                error('The grid (cellCenters) has changed.')
            end 
        end
    end
    if issorted(saveData.t) == 0
        % Rearrange according to time
        disp('   Resorting data according to time indices...')
        [~,sorti]=sort(saveData.t);
        for i = 1:length(saveData.t)
            tNew(i) = saveData.t(sorti(i));
            cellDataNew{i} = saveData.cellData{sorti(i)};
        end
        saveData.t = tNew;
        saveData.cellData = cellDataNew;
    end
    disp(['   Saving data file: ''' ['vtkInfo.' currentFilename '.mat'] '''.'])
    save(['vtkInfo.' currentFilename '.mat'],'-struct','saveData')
end