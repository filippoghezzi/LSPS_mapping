function LSPS(data)
    
    if isempty(data); return; end
    
    par=LSPS_ParametersFile(data);

    %Load Rez
    if exist(fullfile(par.dirOUT,'LSPS_Results.mat'),'file')
        load(fullfile(par.dirOUT,'LSPS_Results.mat'),'rez')
    else
        rez=struct;
    end

    rez=LSPS_CorticalLayers(data,par,rez);


    if isfield(rez,'tmp')
        if par.analyseEverything
            f=fieldnames(rez);
            removeFields=f(~ismember(f,{'layersMap','layersCoordinates','pialDistance','tmp'}));
            rez=rmfield(rez,removeFields);

            rez=LSPS_Mapping(par, rez);     
        end
    else
        rez=LSPS_Mapping(par, rez); 
    end

    %Save rez 
    rez.par=par;
    rez=JS_modifyMaps(rez);
    save(fullfile(par.dirOUT,'LSPS_Results.mat'),'rez')

    LSPS_saveMapImage(rez)
end


function rez=JS_modifyMaps(rez)
    switch rez.par.cellID
        case 'SA155.2'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'SA155.1'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'SA158.2'
           rez.AUCmaps=rez.AUCmaps(1:18,:); 
           rez.layersMap=rez.layersMap(1:18,:);
        case 'LD41.1'
           rez.AUCmaps=rez.AUCmaps(3:end,:); 
           rez.layersMap=rez.layersMap(3:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-3;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-2;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'LD41.2'
           rez.AUCmaps=rez.AUCmaps(4:end,:); 
           rez.layersMap=rez.layersMap(4:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-3;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-3;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'NTSR5.3'
           rez.AUCmaps=rez.AUCmaps(4:end,:); 
           rez.layersMap=rez.layersMap(4:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-3;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-3;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'LD8.1'
           rez.AUCmaps=rez.AUCmaps(1:26,:); 
           rez.layersMap=rez.layersMap(1:26,:); 
        case 'LD12.2'
           rez.AUCmaps=rez.AUCmaps(1:26,:); 
           rez.layersMap=rez.layersMap(1:26,:); 
        case 'LD4.3'
           rez.AUCmaps=rez.AUCmaps(1:26,:); 
           rez.layersMap=rez.layersMap(1:26,:); 
        case 'SA36.6'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'SA38.1'
           rez.AUCmaps=rez.AUCmaps(3:end,:); 
           rez.layersMap=rez.layersMap(3:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-2;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-2;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'SX5.2'
           rez.AUCmaps=rez.AUCmaps(3:end,:); 
           rez.layersMap=rez.layersMap(3:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-2;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-2;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'LI1.2'
           rez.AUCmaps=rez.AUCmaps(1:18,:); 
           rez.layersMap=rez.layersMap(1:18,:);         
        case 'SA2.1'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);  
        case 'LX28.4'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);  
        case 'LX2.2'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);  
        case 'LX5.2'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);  
        case 'LX11.1'
           rez.AUCmaps=rez.AUCmaps(3:end,:); 
           rez.layersMap=rez.layersMap(3:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-2;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-2;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'LX33.4'
           rez.AUCmaps=rez.AUCmaps(1:18,:); 
           rez.layersMap=rez.layersMap(1:18,:); 
        case 'LX35.2'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);    
        case 'LX30.2'
           rez.AUCmaps=rez.AUCmaps(1:18,:); 
           rez.layersMap=rez.layersMap(1:18,:);  
        case 'SA7.3'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:); 
        case 'LX3.1'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:); 
        case 'SX1.1'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'SX2.1'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:); 
        case 'SX2.2'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'SX20.1'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'SX21.2'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'SX22.1'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'SX22.2'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'SX23.1'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'SX23.2'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'LX35.3'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'LX35.4'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);    
        case 'LX36.2'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);             
        case 'LX36.3'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);             
        case 'LX23.3'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);              
        case 'LX23.1'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'LX23.4'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'LX30.3'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'SX20.3'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'LX27.3'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'LX27.1'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;            
        case 'LX24.3'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'LX24.1'
           rez.AUCmaps=rez.AUCmaps(5:end,:); 
           rez.layersMap=rez.layersMap(5:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-4;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-4;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'LX24.2'
           rez.AUCmaps=rez.AUCmaps(3:end,:); 
           rez.layersMap=rez.layersMap(3:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-2;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-2;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'LX9.1'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;        
        case 'LX29.1'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
           
        case 'JS4'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);
        case 'JS19'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS20'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS59'
           rez.AUCmaps=rez.AUCmaps(1:18,:); 
           rez.layersMap=rez.layersMap(1:18,:);
        case 'JS13'
           rez.AUCmaps=rez.AUCmaps(2:20,:); 
           rez.layersMap=rez.layersMap(2:20,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17; 
        case 'JS60'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS30'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);  
        case 'JS9'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:); 
        case 'JS7'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'JS21'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:); 
        case 'JS23'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:); 
        case 'JS65'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'JS66'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'JS67'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS71'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS68'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'JS69'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'JS70'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:); 
        case 'JS62'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:); 
        case 'JS64'
           rez.AUCmaps=rez.AUCmaps(1:18,:); 
           rez.layersMap=rez.layersMap(1:18,:);
        case 'JS72'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS73'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS91'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);
        case 'JS92'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS115'
           rez.AUCmaps=rez.AUCmaps(1:18,:); 
           rez.layersMap=rez.layersMap(1:18,:);
        case 'JS116'
           rez.AUCmaps=rez.AUCmaps(1:18,:); 
           rez.layersMap=rez.layersMap(1:18,:);
        case 'JS22'
           rez.AUCmaps=rez.AUCmaps(2:21,:); 
           rez.layersMap=rez.layersMap(2:21,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'JS1'
           rez.AUCmaps=rez.AUCmaps(3:end,:); 
           rez.layersMap=rez.layersMap(3:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-2;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-2;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'JS2'
           rez.AUCmaps=rez.AUCmaps(3:end,:); 
           rez.layersMap=rez.layersMap(3:end,:);
            rez.cellYcoordinate=rez.cellYcoordinate-2;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-2;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'JS3'
           rez.AUCmaps=rez.AUCmaps(3:end,:); 
           rez.layersMap=rez.layersMap(3:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-2;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-2;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'JS5'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'JS16'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'JS15'
           rez.AUCmaps=rez.AUCmaps(3:end,:); 
           rez.layersMap=rez.layersMap(3:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-2;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-2;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'JS17'
           rez.AUCmaps=rez.AUCmaps(2:end,:); 
           rez.layersMap=rez.layersMap(2:end,:);
           rez.cellYcoordinate=rez.cellYcoordinate-1;
           rez.layersCoordinates.Y=rez.layersCoordinates.Y-1;
           rez.layersCoordinates.Y(1,:)=0;
           rez.layersCoordinates.Y(end,:)=17;
        case 'JS103'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS104'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);
        case 'JS105'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS108'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);
        case 'JS109'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);
        case 'JS101'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);       
        case 'JS102'
           rez.AUCmaps=rez.AUCmaps(1:20,:); 
           rez.layersMap=rez.layersMap(1:20,:);  
        case 'JS100'
           rez.AUCmaps=rez.AUCmaps(1:19,:); 
           rez.layersMap=rez.layersMap(1:19,:);  
        otherwise
    end
end