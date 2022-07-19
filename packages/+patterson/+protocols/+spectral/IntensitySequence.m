classdef IntensitySequence < patterson.protocols.spectral.ContrastSequence
% INTENSITYSEQUENCE
%
% Description:
%   A series of intensity steps
%
% Parent:
%   patterson.protocols.spectral.ContrastSequence
%
% Constructor:
%   obj = IntensitySequence(calibration, varargin)
%
% Inherited properties:
%   stepTime                Time of each step (sec)
%   spectralClass
%   preTime
%   stimTime                Time of each step + return to baseline (sec)
%   tailTime
%   contrast                List of contrasts for each step (positive)
%   baseIntensity           Set to 0
%
% Derived properties:
%   numSteps                Number of steps presented
%
% Notes:
%   - Specialized subclass of patterson.protcols.spectralContrastSequence,
%       the separation into a subclass isn't necessary, just for clarity
% -------------------------------------------------------------------------

    methods
        function obj = IntensitySequence(calibration, varargin)
            obj = obj@patterson.protocols.spectral.ContrastSequence(...
                calibration, varargin{:});

            % Input checking
            assert(nnz(obj.contrast < 0) == 0, 'Contrasts must be positive');

            % Overwrites
            obj.baseIntensity = 0;
        end

        function stim = generate(obj)
            stim = generate@patterson.protocols.spectral.ContrastSequence(obj);
        end

        function fName = getFileName(obj)
            fName = 'intensity_seq';
            for i = 1:obj.numSteps
                fName = sprintf('%s_u%u', fName, 100*obj.contrast(i));
            end
            fName = sprintf('%s_%up_%us_%ut', fName,... 
                100*obj.baseIntensity, obj.stepTime, obj.totalTime);
        end
    end
end 