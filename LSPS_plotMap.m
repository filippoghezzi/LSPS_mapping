function LSPS_plotMap(map,varargin)
% Function to plot LSPS maps.
% Input: map -> matrix of the map to plot;
%    
%     Optional: LayerCoordinates -> 
%               CellCoordinates ->
%               Normalization ->
%               IorE ->
%               BrainArea ->
%               CellType ->
%               Age ->
%               Max ->
%     
    p=inputParser;
    addRequired(p,'map',@(x) isnumeric(x));
    
    addOptional(p,'LayerCoordinates',[]);
    addOptional(p,'CellCoordinates',[]);
    addOptional(p,'Normalization','No',@(x) ischar(x));
    addOptional(p,'IorE',[]);
    addOptional(p,'BrainArea',[]);
    addOptional(p,'CellType',[]);
    addOptional(p,'Age',[]);
    addOptional(p,'Max',[])
    
    parse(p,map,varargin{:});

%% Pre-process map
    map=p.Results.map;
    
    if strcmpi(p.Results.Normalization,'Sum') && sum(map(:))~=0
        map=map./sum(map(:))*100;   
    elseif strcmpi(p.Results.Normalization,'Max') && max(map(:))~=0
        map=map./max(map(:))*100;   
    end
    
%% Plot map
    fontSize=30;
    lineWidth=0.75;
    
    im=imagesc(map);
    im.AlphaData=~isnan(map);
    
    
    ax=gca;
    if ~isempty(p.Results.Max)
        ax.CLim=[0 p.Results.Max];
    end
    ax.FontSize=fontSize;
    ax.Box='off';
    ax.XAxis.Visible='off';
    ax.YAxis.Visible='off';
    daspect([1 1 1])
    
    
%% Plot symbol for cell location
    if ~isnan(p.Results.CellCoordinates)
        for i=1:length(p.Results.CellCoordinates)
            circle((size(map,2)+1)/2,p.Results.CellCoordinates(i),0.3); %%%%ADD triangle for pyramidal cells.
        end
    end
    
%% Add colorbar and legend
    c=colorbar('Location','SouthOutside');
    if strcmpi(p.Results.Normalization,'No')
        c.Label.String='IPSC charge (pC)';
    else 
        c.Label.String='Normalized IPSC charge(%)';
    end
    c.FontSize=fontSize;
    c.LineWidth=lineWidth;
    c.Box='off';
    
%% Map color according to map type
    if strcmp(p.Results.IorE,'Excitatory')
        colormap('jet');
        ax.Color='k';
    elseif strcmp(p.Results.IorE,'Inhibitory')
        colormap('hot');
    end
    
%% Plot layer lines and names
    if ~isempty(p.Results.LayerCoordinates)

        X=p.Results.LayerCoordinates.X;
        Y=p.Results.LayerCoordinates.Y;
        L45=p.Results.LayerCoordinates.L45;
        
        
        hold on
        for k=2:size(Y,1)-1
            plot([X(2)+0.5,X(1)+0.5],[Y(k,1)+0.5,Y(k,2)+0.5],'w','LineWidth',lineWidth,'LineStyle','--');
        end
        
        if strcmp(p.Results.BrainArea,'V1')
            LayersIdx={'L4','L2/3','L1','L5','L6'};
        elseif strcmp(p.Results.BrainArea,'S1BF') && strcmp(p.Results.CellType,'SPN') && p.Results.Age>=5
            LayersIdx={'L4','L2/3',' ','L5a','L6','L5b','SP','WM'};
        elseif strcmp(p.Results.BrainArea,'S1BF') && strcmp(p.Results.CellType,'SPN') && p.Results.Age<5
            LayersIdx={'CP',' ',' ','L5a','L6','L5b','SP','WM'};
        elseif strcmp(p.Results.BrainArea,'S1BF')
            LayersIdx={'L4','L2/3','L1','L5a','L6','L5b'};
        else
            LayersIdx=[];
        end
        
        if ~isempty(LayersIdx)
            text(X(1,1)+0.7, Y(L45,2), LayersIdx{1},'FontSize',fontSize,'Color','w') %L4
            if L45-1>0
                text(X(1,1)+0.7, Y(L45-1,2), LayersIdx{2},'FontSize',fontSize,'Color','w') %L2/3
            end
            
            text(X(1,1)+0.7, Y(L45+1,2), LayersIdx{4},'FontSize',fontSize,'Color','w') %L5 or L5a

            if strcmp(p.Results.BrainArea,'V1')
                text(X(1,1)+0.7, Y(L45+2,2), LayersIdx{5},'FontSize',fontSize,'Color','w') %L6 
                text(X(1,1)+0.7, Y(L45-2,2), LayersIdx{3},'FontSize',fontSize,'Color','w') %L1
            end

            if strcmp(p.Results.BrainArea,'S1BF')
                text(X(1,1)+0.7, Y(L45+2,2), LayersIdx{6},'FontSize',fontSize,'Color','w') %L5b
                text(X(1,1)+0.7, Y(L45+2,2)+2, LayersIdx{5},'FontSize',fontSize,'Color','w') %L6 
            end
            if strcmp(p.Results.BrainArea,'S1BF') && strcmp(p.Results.CellType,'SPN')
                text(X(1,1)+0.7, Y(L45+3,2), LayersIdx{7},'FontSize',fontSize,'Color','w')
                text(X(1,1)+0.7, Y(L45+3,2)+1, LayersIdx{8},'FontSize',fontSize,'Color','w')  
            end 
        end
        
    hold off
    end

end

function h = circle(x,y,r)
    hold on
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    h = plot(xunit, yunit,'w','Linewidth',0.75);
    hold off
end
