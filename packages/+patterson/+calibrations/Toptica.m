classdef Toptica < aod.core.Calibration
% TOPTICACALIBRATION
%
% Description:
%   Nonlinearity in visual stimuli presented with Toptica.
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
    end

    properties (Access = private)
        fitFcn
    end

    methods
        function obj = Toptica(parent)
            if nargin < 0
                parent = [];
            end
            obj = obj@aod.core.Calibration('20210801', parent);
        
            obj.loadCalibration();
        end

        function loadCalibration(obj)
            dataDir = [fileparts(fileparts(mfilename("fullpath"))), filesep, '+resources', filesep];
            data = dlmread([dataDir, 'TopticaNonlinearity2pctPWR.txt']); %#ok<DLMRD> 

            obj.Data = table(data(:,1), data(:,2),...
                'VariableNames', {'Value', 'Power'});
            obj.fitFcn = fit(obj.Data.Value, obj.Data.Power, 'cubicinterp');
        end

        function stim = applyNonlinearity(obj, stim0)
            % APPLYNONLINEARITY
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
                    stim(powerStim == values(i)) = findclosest(lut, values(i));
                end
            else
                for i = 1:numel(powerStim)
                    stim(i) = findclosest(lut, powerStim(i));
                end
            end

            stim = uint8(stim - 1);
            stim = reshape(stim, stimSize);
        end
    end
end