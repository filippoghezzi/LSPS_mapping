clear
close all
clc

addpath(genpath('C:\Users\Butt Lab\Documents\GitHub\LSPS_mapping'))

data=readtable('ExampleData.csv');

if ~isempty(data)
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
            removeFields=f(~ismember(f,{'layersMap','layersCoordinates','pialDistance'}));
            rez=rmfield(rez,removeFields);

            rez=LSPS_Mapping(par, rez);     
        end
    else
        rez=LSPS_Mapping(par, rez); 
    end

    %Save rez 
    rez.par=par;
    save(fullfile(par.dirOUT,'LSPS_Results.mat'),'rez')

    LSPS_saveMapImage(rez)
end
