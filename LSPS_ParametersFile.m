 function par=LSPS_ParametersFile(data)
% Function to set data to analyse and parameters for analysis for LSPS script.
% Input:  
%           data -> loaded data table.
% Output: 
%           par -> parameters structure;

    par.analyseEverything=1;

%% Obtain information from data table
    par.filenames=fullfile(data.foldername,data.CellID,data.filename);
    par.dirOUT=fullfile(data.foldername{1},data.CellID{1},'LSPS_Analysis');
    if ~exist(par.dirOUT,'dir'); mkdir(par.dirOUT); end

    par.mouseID=data.MouseID{1};
    par.mouseAge=data.MouseAge(1);
    par.mouseCoatColor=data.MouseCoatColor{1};
    par.mouseEyesOpen=data.MouseEyesOpen(1);
    par.mouseGenetics=data.MouseGenetics{1};
    par.brainArea=data.BrainArea{1};
    par.sliceOrientation=data.SliceOrientation{1};
    par.cellTarget=data.CellTarget{1};
    par.cellType=data.CellType{1};
    par.cellLayer=data.CellLayer(1);
    par.cellID=data.CellID{1};
    par.cellMorphology=data.CellMorphology{1};
    par.mapNumber=data.MapNumber;
    par.mapCellPosition=data.MapCellPosition;
    par.mapShift=data.MapShift;
    par.mapIorE=data.MapIorE{1};
    par.mapType=data.MapType{1};
    par.mapOrientation=data.MapOrientation{1};
    par.mapTechnology=data.MapTechnology{1};
    par.mapStimulus=data.MapStimulus{1};

    indexDIC=~cellfun('isempty',data.MapDIC);
    if any(indexDIC)
        par.mapDIC=data.MapDIC{indexDIC};
        par.mapCellPositionDIC=par.mapNumber(indexDIC);
    else
        par.mapDIC=NaN;
        par.mapCellPositionDIC=1;
    end

%% Mapping settings
    %Layers
    par.findCorticalLayers=1;%To determine cortical layers starting from DIC images
    par.pialDistance=1; %1, to calculate distance from pial surface
    par.objectiveFOV=885; %objective field of view, um
    
    %Individual maps
    if strcmp(data.MapType{1},'New')
        load('C:\Users\Butt Lab\Documents\GitHub\LSPS\Maps\NewMap.mat','idxMap')
    elseif strcmp(data.MapType{1},'Old')
        load('C:\Users\Butt Lab\Documents\GitHub\LSPS\Maps\OldMap.mat','idxMap')
    end    
    par.mapIdx=idxMap;
    par.filterLow=1000; %Low-pass filtering frequency, 0 skip filtering.
    par.directResponseTime=0.02; %s
    par.monoSynapticInterval=[0.040,0.337];% As per Anastasiades and Butt, 2012. standard = [0.040,0.337]
    par.synapticThreshold=6;
    
    if strcmp(data.MapIorE{1},'Inhibitory')
        par.directResponseMethod='Subtraction'; %'Interpolation': set pixels with direct responses to NaNs and interpolate average map. 'Subtraction': subtract the fitted direct response trace to original trace in each sweep. 
    elseif strcmp(data.MapIorE{1},'Excitatory')
        par.directResponseMethod='Interpolation';
    end
    
    %Average map
    par.removeSingleSpots=0; %1 to remove spots where IPSC are elicited in one and only one of the multiple maps
    par.plotIndividualMap=1; %Plot map image for each analysed file and save
    par.plotAverageMap=1;     %Plot final map each cell and save
    par.averageMapNormalization='No'; %'No' to plot raw map; 'Sum' for sum of all individual map pixels or 'Max' for max value of indiviual map.
    par.formatImages={'-tif','-pdf'}; %Format(s) for saving images with export_fig
    
    par.qualityCheck=0; %Leave 0 during main script running
 end
