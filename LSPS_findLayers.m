function [layersMatrix,layersCoordinates,pialDistance]=LSPS_findLayers(par,imageFile,orientation,age,cellType,cellID,mapType,brainArea)
% Function to manually select layers using an individual DIC image. Once
% the image open, click only on the upper side of it to select layer
% boundaries; after the last point has been selected click Enter on the
% keyboard. Then select the layer boundary on the bottom side of the image
% and click enter. Third selection step involve only clicking on the layer 
% boundary between L4 and L5. Finally, click on the pial surface and then
% on the position of the cell to calculate pial distance. The final layer 
% map will appear; click Enter to continue the script. 
% Inputs:  par -> structure, parameters;
%          imageFile -> directory and image file name;
%          orientation -> string, either Right or Left for pial surface orientation;
%          age -> string, age of animal;
%          cellType -> string, cell type analysed;
%          cellID -> string, ID of cell analysed;
%          mapType -> string, New or Old;
%          brainArea -> string, brain area where cell is recorded. 
% Outputs: layerMatrix -> rowN*colN matrix representing layer distribution;
%          layerCoordinates -> X, Y coordinates of layer boundaries and index of L4-L5 boundary;
%          pialDistance -> value of distance from pial surface, in um.

    warning ('off')
    
    %Define empty matrix according to map type
    if strcmp(mapType,'New')
        load('C:\Users\Butt Lab\Documents\GitHub\LSPS\Maps\NewMap.mat','idxMap')
    elseif strcmp(mapType,'Old')
        load('C:\Users\Butt Lab\Documents\GitHub\LSPS\Maps\OldMap.mat','idxMap')
    end
    rowN=size(idxMap,1);
    colN=size(idxMap,2);
    layersMatrix=zeros(rowN,colN);
    
    
    %Open image and crop
    image=imread(imageFile);
    if strcmp(orientation,'Right')
        image=imrotate(image,180);
    end
    
    if strcmp(mapType,'Old')
        image=imcrop(image);
        close
    end
    
    %Show cropped image
    figure('units','normalized','outerposition',[0 0 1 1]);
    imshow(image,'InitialMagnification','fit')
    hold on
    
    %Draw LSPS grid
    [Ymax,Xmax,~]=size(image);
    for i=1:rowN
        plot([0,Xmax],[Ymax/rowN*i,Ymax/rowN*i],'r:')
    end
    for i=1:colN
        plot([Xmax/colN*i,Xmax/colN*i],[0,Ymax],'r:')
    end
       
    %Select layer points on image
    title(strcat(cellID,' - P',int2str(age),' - ',brainArea,' - L',int2str(cellType),' - Select layer boundaries (upper side)'))
    [Xup,Yup]=getpts; %Upper axis
    plot(Xup,Yup,'*r','MarkerSize',12)
    
    title(strcat(cellID,' - P',int2str(age),' - ',brainArea,'-L',int2str(cellType),' - Select layer boundaries (lower side)'))    
    [Xlo,Ylo]=getpts; %Lower axis
    plot(Xlo,Ylo,'*r','MarkerSize',12)
    
    %Determine L4-L5 boundary for map alignment
    title(strcat(cellID,' - P',int2str(age),' - ',brainArea,'-L',int2str(cellType),' - Select L4-L5 boundary'))    
    [X45,~]=getpts; %L4-L5 boundary
    [~,L45]=min(abs(Xup-X45));
    
    %Determine cell distance from pial surface
    if par.pialDistance
        title(strcat(cellID,' - P',int2str(age),' - ',brainArea,'-L',int2str(cellType),' - Select pial surface then cell position'))
        [Xcell,~]=getpts;
        pialDistance=((Xcell(2)-Xcell(1))*par.objectiveFOV)/Xmax; %Calculated based on total size of the field of view under 10X magnification (885 um).
    else
        pialDistance=NaN;
    end
    close
    
    %Map the points and the line in between on a colN*rowN map
    binX=Xmax/colN;
    binY=Ymax/rowN;
    YindexU=round(Yup(1)/binY);
    YindexL=round(Ylo(1)/binY);
    for i=1:length(Xup)
        XindexU(i)=round((Xup(i)-Xup(1))/binX,0);
        XindexL(i)=round((Xlo(i)-Xlo(1))/binX,0);

        coefficients = polyfit([XindexU(i),XindexL(i)], [YindexU,YindexL], 1);
        a = coefficients (1); %Y=aX+b
        b = coefficients (2);
        line=@(Yl) (Yl-b)/a;

        for y=1:rowN
            x(y,i)=line(y);
        end
    end

    %Build layer matrix
    for i=1:length(Xup)-1   
        for row=1:rowN
            for column=1:colN
                if i==length(Xup)-1
                    if column>x(row,i)
                        layersMatrix(row,column)=i;
                    end            
                else    
                    if column>x(row,i) && column<=x(row,i+1)
                        layersMatrix(row,column)=i;
                    end
                end
            end
        end
    end
    
    %Rotate layer matrix
    layersMatrix=rot90(layersMatrix,3); 
    
    Ycoordinates(:,1)=XindexL';
    Ycoordinates(:,2)=XindexU';
    Xcoordinates(:,1)=YindexU;
    Xcoordinates(:,2)=YindexL;

    %Plot layer matrix and layer boundary lines
    hold on
    imagesc(layersMatrix)
    ax=gca;
    ax.YDir='reverse';
    for i=1:size(Ycoordinates,1)
        if i==L45
            plot([Xcoordinates(1)+0.5,Xcoordinates(2)+0.5],[Ycoordinates(i,1)+0.5,Ycoordinates(i,2)+0.5],'g')
        else
            plot([Xcoordinates(1)+0.5,Xcoordinates(2)+0.5],[Ycoordinates(i,1)+0.5,Ycoordinates(i,2)+0.5],'r')
        end
    end
    pause
    close

    % Generate output variables
    layersCoordinates.Y=Ycoordinates;
    layersCoordinates.X=Xcoordinates;
    layersCoordinates.L45=L45;

    warning ('on')
end