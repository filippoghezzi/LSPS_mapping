function rez=LSPS_averageMaps(par, rez)
% Function to average multiple maps and map positions to obtain the final heat map. 
% Input: 
%           par -> structure containing parameters of data extraction;
%           rez -> structure containing individual map data.
% Output: 
%           rez -> containing average final map. 
    
    [AUC_MAP, CELLCOORD, binMoved12, binMoved23]=linkMaps(par, rez);
    
    if strcmpi(par.directResponseMethod,'Interpolation')
        AUC_MAP=inpaint_nans(AUC_MAP,3);
        AUC_MAP(AUC_MAP<0)=0;
    end
    
    if ~isfield(rez,'tmp')
            [layersMap,layersCoordinates]= updateLayers(rez.layersMap,rez.layersCoordinates,binMoved12,binMoved23,size(AUC_MAP,1),par.mapCellPositionDIC,par.brainArea);
        rez.tmp=rez;
        rez.layersMap=layersMap;
        rez.layersCoordinates=layersCoordinates;
    end
    
    rez.cellYcoordinate=CELLCOORD;
    rez.AUCmaps=AUC_MAP;        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           SUB-FUNCTIONS                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MAP, CELLCOORD, binMoved12, binMoved23]=linkMaps(par, rez)
%% Average individual maps
    Nmaps=unique(par.mapNumber);
    averageMaps=zeros(size(rez.AUCmaps,1),size(rez.AUCmaps,2),numel(Nmaps));
    mapIndex=nan(numel(Nmaps),1);
    
    for i=1:numel(Nmaps)
        singlePositionAllMaps=rez.AUCmaps(:,:,par.mapNumber==Nmaps(i));

        if par.removeSingleSpots
           singlePositionAllMaps=LSPS_removeSingleSpots(singlePositionAllMaps);
        end
        
        %Create average map - single position
        singlePositionAverageMap=nanmean(singlePositionAllMaps,3);
        if strcmpi(par.directResponseMethod,'Interpolation')
            NaN_idx=findNaNs(singlePositionAllMaps);
            singlePositionAverageMap(NaN_idx)=NaN;
        end
        
        averageMaps(:,:,i)=singlePositionAverageMap;
        if ~any(isnan(rez.cellYcoordinate(par.mapNumber==Nmaps(i)))) 
            mapIndex(i,1)=unique(rez.cellYcoordinate(par.mapNumber==Nmaps(i)));
        end
    end

    
    
%% Linking average maps from different positions   
    if numel(mapIndex)==1                                     % Case 1 map 
        MAP=averageMaps;
        binMoved12=0;
        binMoved23=0;
        CELLCOORD=mapIndex;

    elseif numel(mapIndex)>1                                  % Case 2 maps
  
        %Find bin moved between maps 1 and 2 and stich maps 1 and 2
        if ~isnan(mapIndex(1)) && ~isnan(mapIndex(2))
            binMoved12=mapIndex(2)-mapIndex(1);
        elseif ~isnan(mapIndex(1)) && isnan(mapIndex(2))
            mapShift=unique(par.mapShift(~isnan(par.mapShift)));
            binMoved12=mapShift/50;                                            %%Check sign of bin moved to account for direction of movement
        end

        if binMoved12>0
            averageMapPortion12=nanmean(cat(3,averageMaps(1:end-binMoved12,:,1),averageMaps(binMoved12+1:end,:,2)),3);
            map12=[averageMaps(1:binMoved12,:,2);averageMapPortion12;averageMaps(end-binMoved12+1:end,:,1)];

            if isnan(mapIndex(2))
                CELLCOORD=mapIndex(1)+binMoved12;
            else
                CELLCOORD=mapIndex(2);
            end

        elseif binMoved12<0
            binMoved12_adj=abs(binMoved12);
            averageMapPortion12=nanmean(cat(3,averageMaps(binMoved12_adj+1:end,:,1),averageMaps(1:end-binMoved12_adj,:,2)),3);
            map12=[averageMaps(1:binMoved12_adj,:,1);averageMapPortion12;averageMaps(end-binMoved12_adj+1:end,:,2)];

            CELLCOORD=mapIndex(1);
        
        elseif binMoved12==0
            error('binMoved==0 for %s',par.cellID);
        end

        if ~exist('map12','var')
            error('map12 does not exist for %s',par.cellID);
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    FIX WITH ONE EXAMPLE
        if numel(mapIndex)>=3 %3 map positions
            error('3 Maps')
% Case 3 maps 
%                 
%                 %Find bin moved between maps 2 and 3
%                 if ~isnan(mapIndex(2)) && ~isnan(mapIndex(3))
%                     binMoved23=mapIndex(3)-mapIndex(2);
%                 elseif ~isnan(mapIndex(2))&& isnan(mapIndex(3))
%                     mapShift=unique(par.mapShift(rez.cellYcoordinate==mapIndex(3)));
%                     binMoved23=mapShift/50; 
%                 end
%                 binMoved23_adj=abs(binMoved23);
% 
%                 if binMoved23>0
%                     averageMapPortion23=map12(1:end-binMoved12_adj-binMoved23_adj,:)+averageMaps{1,3}(binMoved23_adj+1:end,:)./2;
%                     MAP=[averageMaps{1,3}(1:binMoved23_adj,:);averageMapPortion23;map12(end-binMoved12_adj-binMoved23_adj+1:end,:)];
% 
%                     if isnan(mapIndex(3))
%                         CELLCOORD=mapIndex(2)+binMoved23;
%                     else
%                         CELLCOORD=mapIndex(3);
%                     end
%                 end
% 
%                 if binMoved23<0
%                     averageMapPortion23=map12(binMoved12_adj+binMoved23_adj+1:end,:)+averageMaps{1,3}(1:end-binMoved23_adj,:)./2;
%                     MAP=[map12(1:binMoved12_adj+binMoved23_adj,:);averageMapPortion23;averageMaps{1,3}(end-binMoved23_adj+1:end,:)];
%                     CELLCOORD=mapIndex(1);             
%                 end
%             end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        else
            MAP=map12;
            binMoved23=0;  
        end
    end
end


function [LayersMap,LayersCoordinates]=updateLayers(map,coordinates,binMoved12,binMoved23,totalMapY,mapNumber,brainArea)
 %% Update layer coordinates to match the final map    

    if binMoved12==0
        LayersCoordinates=coordinates;
        LayersMap=map;

    elseif mapNumber==1 && binMoved12>0
        coordinates.Y=coordinates.Y+binMoved12+binMoved23;
        LayersCoordinates=coordinates;
        LayersMap=[ones(totalMapY-size(map,1),size(map,2))*map(1,1);map];        

    elseif mapNumber==1 && binMoved12<0 
        LayersCoordinates=coordinates;
        if strcmp(brainArea,'S1BF') && map(end,end)==5
             n=1;
        else 
             n=0;
        end
        LayersMap=[map;ones(totalMapY-size(map,1),size(map,2))*(map(end,end)+n)];        

    elseif mapNumber==2 && binMoved12>0

        if binMoved23>0
            coordinates.Y=coordinates.Y+binMoved23;
            LayersCoordinates=coordinates;
            LayersMap=[ones(binMoved23,size(map,2))*map(1,1);map;ones(binMoved12,size(map,2))*map(end,end)];        

        else 
            LayersCoordinates=coordinates;
            if strcmp(brainArea,'S1BF') && map(end,end)==5
                n=1;
            else 
                n=0;
            end
            LayersMap=[map;ones(totalMapY-size(map,1),size(map,2))*(map(end,end)+n)];
        end

    elseif mapNumber==2 && binMoved12<0
        coordinates.Y=coordinates.Y-binMoved12-binMoved23;
        LayersCoordinates=coordinates;
        LayersMap=[ones(totalMapY-size(map,1),size(map,2))*map(1,1);map];        
    end
end
   
function NaN_idx=findNaNs(maps)
    if size(maps,3)==1
        NaN_idx=isnan(maps);
    elseif size(maps,3)>1
        for i=1:size(maps,3)
            mapNaNs(:,:,i)=isnan(maps(:,:,i));
        end
        mapNaNs=sum(mapNaNs,3);

        NaN_cutoff=size(maps,3)-1;
        NaN_idx=(mapNaNs >= NaN_cutoff);
    end
end

function maps=LSPS_removeSingleSpots(maps)
% Function to remove IPSC occurring only in one of the map repetitions.
% Input: 
%           maps -> 3-dimensional array with maps repetitions as 3rd dimension.
% Output:
%           maps -> updated maps array.

    if size (maps,3)>1
        for i=1:size(maps,1)
            for j=1:size(maps,2)
                c=0;
                for k=1:size(maps,3)
                    if maps(i,j,k)==0
                        c=c+1;
                    end
                end
                if c>=size(maps,3)-1
                    maps(i,j,:)=0;
                end
            end
        end
    end
end