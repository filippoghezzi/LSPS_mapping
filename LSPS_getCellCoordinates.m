function cellCoordinates=LSPS_getCellCoordinates(idxMap,cellPosition,orientation)
% Function to extrapolate cell coordinates (output) within the 11x17 grid. 
% Inputs: idxMap -> matrix, index map;
%         cellPosition -> scalar, between 1 and max(idxMap);
%         orientation -> string, "Left" or "Right" for pial surface on the left or right side, respectively.
% Output: cellCoordinates -> scalar, Y cell coordinates in the grid, relative to upper side of the map.
    

    MiddleRowIdx=(size(idxMap,1)+1)/2;
    MiddleRow=idxMap(MiddleRowIdx,:);

    if strcmp(orientation,'Left')   
        switch cellPosition
            case MiddleRow(1)
                cellCoordinates=1;
            case MiddleRow(2)
                cellCoordinates=2;
            case MiddleRow(3)
                cellCoordinates=3;
            case MiddleRow(4)
                cellCoordinates=4;
            case MiddleRow(5)
                cellCoordinates=5;
            case MiddleRow(6)
                cellCoordinates=6;
            case MiddleRow(7)
                cellCoordinates=7;
            case MiddleRow(8)
                cellCoordinates=8;
            case MiddleRow(9)
                cellCoordinates=9;
            case MiddleRow(10)
                cellCoordinates=10;
            case MiddleRow(11)
                cellCoordinates=11;
            case MiddleRow(12)
                cellCoordinates=12;
            case MiddleRow(13)
                cellCoordinates=13;
            case MiddleRow(14)
                cellCoordinates=14;
            case MiddleRow(15)
                cellCoordinates=15;
            case MiddleRow(16)
                cellCoordinates=16;
            case MiddleRow(17)
                cellCoordinates=17;
            otherwise
                cellCoordinates=NaN;
        end

    elseif strcmp(orientation,'Right')
        switch cellPosition
            case MiddleRow(1)
                cellCoordinates=17;
            case MiddleRow(2)
                cellCoordinates=16;
            case MiddleRow(3)
                cellCoordinates=15;
            case MiddleRow(4)
                cellCoordinates=14;
            case MiddleRow(5)
                cellCoordinates=13;
            case MiddleRow(6)
                cellCoordinates=12;
            case MiddleRow(7)
                cellCoordinates=11;
            case MiddleRow(8)
                cellCoordinates=10;
            case MiddleRow(9)
                cellCoordinates=9;
            case MiddleRow(10)
                cellCoordinates=8;
            case MiddleRow(11)
                cellCoordinates=7;
            case MiddleRow(12)
                cellCoordinates=6;
            case MiddleRow(13)
                cellCoordinates=5;
            case MiddleRow(14)
                cellCoordinates=4;
            case MiddleRow(15)
                cellCoordinates=3;
            case MiddleRow(16)
                cellCoordinates=2;
            case MiddleRow(17)
                cellCoordinates=1;
            otherwise
                cellCoordinates=NaN;
        end
    end

end