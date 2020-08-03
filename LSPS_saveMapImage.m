function LSPS_saveMapImage(rez)

% Plot map from individual abf file and save
    if rez.par.plotIndividualMap
        LSPS_plotIndividualMap(rez);
    end

    if rez.par.plotAverageMap
        LSPS_plotAverageMap(rez);
    end 
end
    