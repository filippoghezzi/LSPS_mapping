function rez=LSPS_CorticalLayers(data,par,rez)
% Parent function for LSPS_findLayers. It runs that function for every item
% in the data table and introduces exceptions for which DIC image is not
% available. Updated data is saved every loop and at the very end. 

    if par.findCorticalLayers
        for i=1:height(data)
            if ~any(isempty(data.MapDIC{i})) && ~isfield(rez,'layersMap')%exist(data.LayersMap{i},'file')
                DICfilename=fullfile(data.foldername{i},data.CellID{i},data.MapDIC{i});
                
                [rez.layersMap,rez.layersCoordinates,rez.pialDistance]=LSPS_findLayers(par,DICfilename,data.MapOrientation(i),data.MouseAge(i),data.CellLayer(i),data.CellID(i),data.MapType(i),data.BrainArea(i));  
                      
            end
        end
        
        save(fullfile(par.dirOUT,'LSPS_Results.mat'),'rez')
    end  
    
end