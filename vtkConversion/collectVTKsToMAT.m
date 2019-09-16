%% Convert a folder of instantaneous VTKs to MATLAB format

%% Setup
% source files
t_array = 20005:5:20020; % Time instances to convert
mainFolder = 'O:\RE19.6turb.varyingWsWd.mixedOLCL\sliceDataInstantaneous'; % Main folder

% Destination file
filenameMat = 'D:\bmdoekemeijer\My Documents\SurfDrive\MATLAB\plotREvideo\vtkInfo.mat';

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
            disp(['  Processing time instant ' num2str(t) '.']); tic();
            saveData.t_array = [t]; 
            [~,saveData.cellCenters,saveData.cellDataArray{ti}] = importVTK([currentFolder filesep currentFilename]);
        else
            disp(['  Processing time instant ' num2str(t) '. Prev iteration: ' num2str(toc) ' s.']); tic();
            [~,cellCentersTmp,saveData.cellDataArray{ti}] = importVTK([currentFolder filesep currentFilename]);
            saveData.t_array = [saveData.t_array t];
            if max(max(abs(cellCentersTmp-saveData.cellCenters))) > 1e-6
                error('The grid (cellCenters) has changed.')
            end 
        end
    end
    if issorted(saveData.t_array) == 0
        % Rearrange according to time
        disp('   Resorting data according to time indices...')
        [~,sorti]=sort(saveData.t_array);
        for i = 1:length(saveData.t_array)
            tNew(i) = saveData.t_array(sorti(i));
            cellDataArrayNew{i} = saveData.cellDataArray{sorti(i)};
        end
        saveData.t_array = tNew;
        saveData.cellDataArray = cellDataArrayNew;
    end
    disp(['   Saving data file: ''' ['vtkInfo.' currentFilename '.mat'] '''.'])
    save([filenameMat(1:end-3) currentFilename(1:end-4) '.mat'],'-struct','saveData','-v7.3')
end