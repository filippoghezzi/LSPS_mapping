clear 
close all
clc

dir=fullfile(cd,'Example');
filename='ExampleData.csv';

data=readtable(fullfile(dir,filename));
cellIDs=unique(data.CellID);
% cellIDs={'SX37.4'};


for ID=1:numel(cellIDs)
    fprintf('ANALYSING: %s\n',cellIDs{ID})
    dataSub=data(strcmp(data.CellID,cellIDs{ID}),:);

    LSPS(dataSub(strcmp(dataSub.Experiment,'LSPS'),:));
    
    fprintf('DONE %d on %d: %s\n',ID, numel(cellIDs), cellIDs{ID})
end
