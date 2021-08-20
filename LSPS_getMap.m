function [outputMap]=LSPS_getMap(data,par,varargin)
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
    addOptional(p, 'CellCoordinates' ,NaN , @(x) isnumeric(x));
    parse(p,data,par,varargin{:});

    sr=par.sr;
    current=data(1,:);
    laser=data(2,:);
    time=(0:length(current)-1)/sr;
    idxMap=par.mapIdx;
    sweepLaserLag=0.020;
    plotting=p.Results.Plotting;
    cellCoordinates=p.Results.CellCoordinates;
    
    conditionDef=@(x) x:x+(par.monoSynapticInterval(2)*sr);
    monoSynapticDef=@(x) x+(par.monoSynapticInterval(1)*sr):x+(par.monoSynapticInterval(2)*sr); 
    baselineDef=@(x) x-(0.01*sr):x;
    
    if strcmp(par.mapIorE,'Excitatory')
        current=-current;
    end
    
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
    directResponsesSweeps=[];
%% Measure AUC at each laser location
    AUC=zeros(length(laserONidx),1);
    IPSC=zeros(length(laserONidx),1);
    peakLoc=zeros(length(laserONidx),1);
    
    for sweep=1:numel(laserONidx)

% Build windows and logic vectors
        conditionWindow=conditionDef(laserONidx(sweep));
        monoSynapticWindow=monoSynapticDef(laserONidx(sweep));  
        if sweep==1
            baselineWindow=baselineDef(laserONidx(sweep+1));
        else
            baselineWindow=baselineDef(laserONidx(sweep));
        end
        
%Condition 1. Determine if measuring the AUC: one point in the condition window higher or lower than (synapticThreshold) std of the baseline. 
        conditionEvent=abs(current(conditionWindow)-mean(current(baselineWindow)))>par.synapticThreshold*std(current(baselineWindow));
%Condition 2. Determine if there is a direct response according to par.directResponseTime. For inhibitory maps, add the conditions related to direction of current deflections. 
        if strcmp(par.mapIorE,'Excitatory')
            if strcmp(par.directResponseOnsetMethod,'First')
                conditionDirectResponses=find(conditionEvent,1,'first')/sr<par.directResponseTime;
            elseif strcmp(par.directResponseOnsetMethod,'Last')
                [~, directResponseIdx] = max(current(conditionWindow)-mean(current(baselineWindow)));
                directResponseWindow = (laserONidx(sweep): directResponseIdx+laserONidx(sweep));
                conditionDirectResponses=current(directResponseWindow)-mean(current(baselineWindow))<1*std(current(baselineWindow));
                conditionDirectResponses=find(conditionDirectResponses,1,'last')/sr<par.directResponseTime;
            end
    
        elseif strcmp(par.mapIorE,'Inhibitory')
            conditionDirectResponses=(find(conditionEvent,1,'first')/sr<par.directResponseTime & current(find(conditionEvent,1,'first'))<mean(current(baselineWindow)));
        end
        
        if any(conditionEvent)
            if conditionDirectResponses
                directResponsesSweeps = [directResponsesSweeps;sweep];
                startSweep=laserONidx(sweep)-sweepLaserLag*sr;
                endSweep=laserONidx(sweep)+(1*sr);
                if startSweep<1
                    startSweep=1;
                end 
                if endSweep>length(current)
                    endSweep=length(current);
                end
                [AUC(sweep,1),peakLoc(sweep,1)]=directResponse(current(startSweep:endSweep),par,sweepLaserLag*sr);                    
            else
                AUC(sweep,1)=trapz(current(monoSynapticWindow)-mean(current(baselineWindow)));
                [IPSC(sweep,1),peakLoc(sweep,1)]=max(current(monoSynapticWindow)-mean(current(baselineWindow)));
            end
        end
    end
%    directResponsesSweeps 
% Remove negative values of AUC (too large direct responses in inhibitory maps or noise).
    AUC(AUC<0)=0;
    IPSC(IPSC<0)=0;
            
    if strcmp(par.mapTechnology,'UGA-40')
        AUC=correctUGA40(AUC);
        if numel(AUC) < numel(idxMap)
            AUC=[AUC;0];
        end
    end
    
%% Build heatmap
    if  par.IPSCmap
        outputMap=IPSC(idxMap);
    else
        outputMap=AUC(idxMap);
    end

    %Rotate maps according to slice orientation
    if strcmp(par.mapOrientation,'Right')
        rotationcoff=1;
    elseif strcmp(par.mapOrientation,'Left')
        rotationcoff=3;
    end
    outputMap=rot90(outputMap,rotationcoff); 

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
        LSPS_plotMap(AUC(idxMap),'IorE',par.mapIorE,'CellCoordinates',cellCoordinates)
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           SUB-FUNCTIONS                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [AUC,peakLoc]=directResponse(current,par,laserONIdx)
% Managing direct responses by interpolation (here setting NaN) or
% subtracting direct response signal by high pass filtering the raw trace
% to remove low-frequency components. 

    if strcmpi(par.directResponseMethod,'Interpolation')
        AUC=NaN;
        peakLoc=NaN;
        
    elseif strcmpi(par.directResponseMethod,'Subtraction')
        baselineWindow=(1:laserONIdx);
        monoSynapticWindow=laserONIdx+(par.monoSynapticInterval(1)*par.sr):laserONIdx+(par.monoSynapticInterval(2)*par.sr); 
        
        %Calculate AUC witout subtraction
        AUC=trapz(current(monoSynapticWindow)-mean(current(baselineWindow)));
        [~,peakLoc]=max(current(monoSynapticWindow)-mean(current(baselineWindow)));
        
        if strcmpi(par.mapIorE,'Inhibitory') && AUC>0 %In this case, direct response is negligible
            return;
        else
        
            % Filtering method to remove low-frequency direct responses and maintain only high-frequency synaptic events.
            [b,a]=butter(3,50/par.sr/2,'high');
            filt_current=filtfilt(b,a,current);
            
            %Plotting
            plotting=0;
            if plotting
                figure
                plot(current)%-mean(current(1:laserONIdx)))
                hold on
                plot(filt_current)                
            end
        
            % Re-calculate AUC, peakLoc on filtered trace
            AUC=trapz(filt_current(monoSynapticWindow));
            [~,peakLoc]=max(filt_current(monoSynapticWindow));
        end
        
    end
end
  

function data=correctUGA40(data)

% Correction for old map (UGA-40), first TTL is actually spot 2; spot 1 not recorded. 
    corr_data=[0;data];
    corr_data(end)=[];
    data=corr_data;
end