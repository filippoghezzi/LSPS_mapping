function [map,spikeTimes]=LSPS_getMap_Extracellular(data,par,varargin)
% function [AUCmap,traceMap,Pmap]=LSPS_generateMap(trace,sr,par,plotting)
% Function to obtain AUC map from the raw data in input.
% Possibility to plot output map and trace.
%
% Inputs:   data -> matrix, containing VC data (first row), and stimulus
%                   (laser) logical vector (second row).
%           par -> struct, containing following fields:
%                   sr -> numeric, sampling rate                    
%                   mapIdx -> matrix, indexes of map
%                   monoSynapticInterval -> 2-element vector in s
%                   directResponseTime -> numeric in s
%                   synapticThreshold -> numeric
%                   mapOrientation -> 'Left' or 'Right'
%                   directResponseMethod -> 'Interpolation' or 'Subtraction'                    
%                   mapIorE -> 'Inhibitory' or 'Excitatory'
%                   mapTechnology -> 'UGA40' or 'UGA42'
%
% Outputs:  AUCmap -> final map of AUC data
    
%% Input parser and variables
    p=inputParser;
    addRequired(p, 'data', @(x) isnumeric(x));
    addRequired(p, 'par', @(x) isstruct(x));
    addOptional(p, 'Plotting', false, @(x) islogical(x));
    addOptional(p, 'CellPosition' ,NaN , @(x) isnumeric(x));
    parse(p,data,par,varargin{:});

    sr=par.sr;
    current=-data(1,:); %Minus sign to flip traces vertically so that APs are upward (positive)
    laser=data(2,:);
    time=(0:length(current)-1)/sr;
    idxMap=par.mapIdx;
    plotting=p.Results.Plotting;
    cellPosition=p.Results.CellPosition;
    
    spikingWindowDef=@(x) x:x+(par.monoSynapticInterval(2)*sr);
    
    if any(isnan(laser))
        if strcmp(par.mapStimulus,'Glutamate')
            load('C:\Users\Butt Lab\Documents\GitHub\LSPS_mapping\Maps\laserTrace_Glutamate.mat','laser')
        elseif strcmp(par.mapStimulus,'ATP')
            load('C:\Users\Butt Lab\Documents\GitHub\LSPS_mapping\Maps\laserTrace_ATP.mat','laser')
        end
    end
    
    %% Find laser onset
    [~,laserONidx]=findpeaks(diff(laser),'MinPeakHeight',1,'MinPeakDistance',0.500*sr);
    
    if size(laserONidx,2)~=numel(idxMap) && ~strcmp(par.mapTechnology,'UGA-40')
        warning('Found %d laser spots against %d spots in the index map',size(laserONidx,2),numel(idxMap))
    end
    
    %% Find AP in data
    [~,AP_locs] = findpeaks(current, 'MinPeakHeight', 9*std(current)+mean(current), 'MinPeakDistance', 0.005*sr, 'MinPeakWidth', 0.0002*sr, 'Annotate', 'extents');
    
%% Measure AUC at each laser location
    spikesN=zeros(length(laserONidx),1);    
    for sweep=1:numel(laserONidx)
        spikingWindow=spikingWindowDef(laserONidx(sweep));
        spikesIdx=ismember(AP_locs,spikingWindow);
        spikeTimes{sweep,1}=(AP_locs(spikesIdx)-laserONidx(sweep))/sr;
        spikesN(sweep,1)=nnz(spikesIdx);
    end
    spikeTimes=spikeTimes{cellPosition,1};
    
%% Build heatmap
    map=spikesN(idxMap);
    %Rotate maps according to slice orientation
    if strcmp(par.mapOrientation,'Right')
        rotationcoff=1;
    elseif strcmp(par.mapOrientation,'Left')
        rotationcoff=3;
    end
    map=rot90(map,rotationcoff); 

%%  Plotting current and IPSC peak    
    if plotting
        idxZeros=peakLoc~=0; %Check Remove zeros
        peakLoc=peakLoc+laserONidx'+(par.monoSynapticInterval(1)*sr);
        peakLoc=peakLoc(idxZeros);
        currentToPlot=detrend(current);
        
        figure('units','normalized','outerposition',[0 0 1 1]);
        subplot(4,1,1)
        hold on
        plot(time,currentToPlot,'k')
        for sweep=1:length(laserONidx)
            plot([laserONidx(sweep)/sr,laserONidx(sweep)/sr],[100,-100],'c--')
        end
        plot(peakLoc/sr,currentToPlot(peakLoc),'r*')
        ylim([min(currentToPlot) max(currentToPlot)])
        xlim([min(time) max(time)])
        
        subplot(4,1,2:4)
        LSPS_plotMap(AUC(idxMap),'IorE',par.mapIorE)
    end
end
