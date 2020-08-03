function LSPS_plotAverageMap(rez)
% Function to plot final average maps contained in the input structure. Wrap
% LSPS_plotMap and save the fig file.
        
    figure('units','normalized','outerposition',[0 0 1 1]);
    par=rez.par;    
    
    LSPS_plotMap(rez.AUCmaps,'CellCoordinates',rez.cellYcoordinate,'LayerCoordinates',rez.layersCoordinates,'IorE',par.mapIorE,'BrainArea',par.brainArea,'Normalization',par.averageMapNormalization)

    title(strcat(par.cellID,' - ',par.brainArea,' - ',par.cellTarget,'-',par.cellType,' - L',num2str(par.cellLayer),' - P',num2str(par.mouseAge),' - '),'FontSize',23)
    figname=fullfile(par.dirOUT,par.cellID);
    export_fig(figname,par.formatImages{1,:})
    
    if ~par.qualityCheck 
        close
    end
end