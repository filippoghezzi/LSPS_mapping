function [outputTrace,sr,Vh]=loadData_VC(filename,varargin)
% function [outputTrace,sr,Vh]=LSPS_loadData(filename,varargin)
%
% Load electrophysiological data from filename with abfload in VC. 
% Return a individual file containing current trace and stimulus signal. 
% Filter with low-pass butterworth filter if varargin contains
% frequency for filtering. 
%
% Inputs:
%       filename -> string, full name of the file to load;
%       'LowPassFrequency' -> frequency of low pass filtering or 0 to avoid
%                       filtering.
% Outputs:
%       trace -> time-series with current trace (first row) and laser trace
%           (second row).
%       sr -> sampling rate;
%       Vh -> mean holding voltage.

%% Input parser and variables
    p=inputParser;
    addRequired(p, 'filename', @(x) ischar(x));
    addOptional(p, 'LowPassFrequency', 0, @(x) isnumeric(x));
    parse(p,filename,varargin{:});
    fLow=p.Results.LowPassFrequency;
    
%% Load with abfload
    [data,si,h]=abfload(filename); 
    sr=1/(si*10^-6);    %Samling Rate; Hz

    if size(data,1)==100000
        data=data(1:40000,:,:);
    end

% Obtain channel type according to units (I assume more robust across time than channel name).
    currentChIdx=find(strcmp(h.recChUnits,'pA'),1);
    voltageChIdx=find(strcmp(h.recChUnits,'mV'),1);
    laserChIdx=find(strcmp(h.recChUnits,'V'),1);

%% Generate individual time series from sweeps
    sweepsSamples=size(data,1);
    sweepsTot=size(data,3);

    current=zeros(sweepsSamples*sweepsTot,1);
    voltage=zeros(sweepsSamples*sweepsTot,1);
    laser=zeros(sweepsSamples*sweepsTot,1);
    
    flag=0;
    for sweep=1:sweepsTot
        if any(currentChIdx)
            current(sweepsSamples*(sweep-1)+1:sweepsSamples*sweep)=data(:,currentChIdx,sweep);
        else
            error('No current sweep identified')
        end
        
        if any(voltageChIdx)
            voltage(sweepsSamples*(sweep-1)+1:sweepsSamples*sweep)=data(:,voltageChIdx,sweep);
        else
            flag=1;
        end
                
        if any(laserChIdx)
            laser(sweepsSamples*(sweep-1)+1:sweepsSamples*sweep)=data(:,laserChIdx,sweep);
        else
            error('No laser sweep identified')
        end
    end
    
    if flag
        warning('No voltage sweep identified - setting Voltage = NaN')
        voltage=NaN;
    end

%% Low pass filtering
    if fLow~=0
        [b,a]=butter(3,fLow/(sr/2),'low');
        current=filtfilt(b,a,current);
    end

%% Generate output variables
    outputTrace(1,:)=current;
    outputTrace(2,:)=laser;
    Vh=mean(voltage);
    
end