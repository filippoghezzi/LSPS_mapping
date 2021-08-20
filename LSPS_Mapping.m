function rez=LSPS_Mapping(par, rez)
% Parent function for LSPS_getMap and LSPS_averageMaps. 
% Inputs:
%           data -> data table;
%           par -> parameters structure;
% Outputs:
%           data -> updated data table;
%           results -> results table.


%% Main data analysis: obtain individual maps and cell coordinates from individual recording file
    for i=1:size(par.filenames,1)
        [trace, par.sr, rez.Vh] = loadData_VC(par.filenames{i}, 'LowPassFrequency',par.filterLow);
        if strcmp(par.mapIorE,'Extracellular')
            [rez.AUCmaps(:,:,i), rez.spikeTimes{i}] = LSPS_getMap_Extracellular(trace, par, 'Plotting',false, 'CellPosition', par.mapCellPosition(i));
        elseif  strcmp(par.mapIorE,'Inhibitory')
            rez.AUCmaps(:,:,i) = LSPS_getMap(trace, par, 'Plotting',false);
        elseif strcmp(par.mapIorE,'Excitatory')
            rez.AUCmaps(:,:,i) = LSPS_getMap_fromCSV(par.csvFiles{i}, trace, par, 'Plotting',false);
        end
        
        rez.cellYcoordinate(i) = LSPS_getCellCoordinates(par.mapIdx, par.mapCellPosition(i), par.mapOrientation);
    end
    
%% Produce final average map 
    [rez]=LSPS_averageMaps(par,rez);
    
end