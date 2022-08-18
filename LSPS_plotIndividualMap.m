function LSPS_plotIndividualMap(rez)
% Function to plot individual maps contained in the table data. Wrap
% LSPS_plotMap, build subplots for each map, and save the fig file.

    figure('units','normalized','outerposition',[0 0 1 1]);
    par=rez.par;

    maxNindividualMap=0;
    uniqueMaps=unique(par.mapNumber);
    for i=1:numel(uniqueMaps)
        if nnz(par.mapNumber==uniqueMaps(i)) > maxNindividualMap
            maxNindividualMap=nnz(par.mapNumber==uniqueMaps(i));
        end
    end
    
    j=1;
    k=1;
    z=1;
    
    for i=1:numel(par.mapNumber)        
        if par.mapNumber(i)==1
            subplot(max(par.mapNumber),maxNindividualMap,j)
            j=j+1;
        elseif par.mapNumber(i)==2
            subplot(max(par.mapNumber),maxNindividualMap,k+maxNindividualMap)
            k=k+1;
        elseif par.mapNumber(i)==3
            subplot(max(par.mapNumber),maxNindividualMap,z+(2*maxNindividualMap))
            z=z+1;
        end
        
        if par.mapNumber(i)==par.mapCellPositionDIC
            layerCoordinates=rez.tmp.layersCoordinates;
        else
            layerCoordinates=[];
        end
        
        LSPS_plotMap(rez.tmp.AUCmaps(:,:,i),'CellCoordinates',rez.tmp.cellYcoordinate(i),...
            'LayerCoordinates',layerCoordinates,'IorE',par.mapIorE,'BrainArea',par.brainArea)
        
        if ~isempty(par.mapLaserPower)
            t=title(strcat(par.filenames{i}(end-11:end),' - Power=',int2str(par.mapLaserPower(i)*10)));
        else
            t=title(par.filenames{i}(end-11:end));
        end
        t.FontSize=12;
    end
    
    % Choose laser power for spike time analysis for extracellular
    % calibration recordings
    if ~isempty(par.mapLaserPower)
        opts.Resize='on';
        opts.WindowStyle='normal';
        opts.Interpreter = 'tex';
        laserPower=inputdlg('Choose laser power                                           \color{white} .','Laser calibration',1,{'10-50'},opts);
        rez.par.mapSelectedLaserPower=str2double(laserPower{1});
        rez.spikeTimes=rez.spikeTimes(par.mapLaserPower*10==rez.par.mapSelectedLaserPower);
        save(fullfile(par.dirOUT,'LSPS_Results.mat'),'rez')
    end
    savefig(fullfile(par.dirOUT,'IndividualMaps.fig'))
%     pause
    if ~par.qualityCheck
        close
    end
            
end

