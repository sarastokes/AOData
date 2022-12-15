classdef TopticaNonlinearity < aod.core.Calibration
% TOPTICANONLINEARITY
%
% Description:
%   Nonlinearity in visual stimuli presented with Toptica.
%
% Parent:
%   aod.core.Calibration
%
% Syntax:
%   obj = TopticaNonlinearity(calibrationDate, laserLine)
%
% Methods:
%   loadCalibration(obj)
%   setFitFunction(obj)
%   stim = applyNonlinearity(obj, stim)
%
% Note:
%   The Toptica's output is linear, the nonlinearity arises through the
%   modulation performed by the imaging software. Thus, this applies to all
%   wavelengths and baseline Toptica output levels.  The measurement here
%   was made at 2% on the Toptica and checked in Nov 2021 with other
%   Toptica output levels.
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data 
        laserLine
    end

    properties (SetAccess = private)
        fitFcn
    end

    methods
        function obj = TopticaNonlinearity(laserLine, calibrationDate)
            if nargin < 1
                laserLine = 561;
            end
            if nargin < 2
                calibrationDate = '20210810';
            end
            obj = obj@aod.core.Calibration([], calibrationDate);
            obj.laserLine = laserLine;
        
            obj.loadCalibration();
        end

        function loadCalibration(obj)
            dataDir = fullfile(fileparts(fileparts(mfilename("fullpath"))), '+resources');
            fileName = fullfile(dataDir, 'TopticaNonlinearity20200810.txt');
            data = dlmread(fileName); %#ok<DLMRD> 
            obj.setFile('NonlinearityFile', fileName);

            obj.Data = table(data(:,1), data(:,2),...
                'VariableNames', {'Value', 'Power'});
            obj.setFitFunction();
        end
        
        function setFitFunction(obj)
            obj.fitFcn = fit(obj.Data.Value, obj.Data.Power, 'cubicinterp');
        end

        function stim = applyNonlinearity(obj, stim0)
            % APPLYNONLINEARITY
            if isempty(obj.fitFcn)
                obj.setFitFunction();
            end
            lut = obj.fitFcn(0:255);

            powerRange = max(obj.Data.Power) - min(obj.Data.Power);
            powerStim = powerRange * stim0 + min(obj.Data.Power);

            stimSize = size(powerStim);
            powerStim = powerStim(:);
            stim = zeros(size(powerStim));

            % If there's just a few unique values, don't run point by point
            values = unique(powerStim);
            if numel(values) < 10
                for i = 1:numel(values)
                    stim(powerStim == values(i)) = sara.util.findclosest(lut, values(i));
                end
            else
                for i = 1:numel(powerStim)
                    stim(i) = sara.util.findclosest(lut, powerStim(i));
                end
            end

            stim = uint8(stim - 1);
            stim = reshape(stim, stimSize);
        end
    end
end