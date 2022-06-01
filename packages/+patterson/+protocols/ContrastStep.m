classdef ContrastStep < aod.builtin.protocols.SpatialProtocol
% CONTRASTSTEP
%
% Description:
%   A spatially-uniform change in intenstiy
% -------------------------------------------------------------------------
    methods
        function obj = ContrastStep(stimTime, varargin)
            obj = obj@aod.builtin.protocols.SpatialProtocol(stimTime, varargin{:});
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(obj.canvasSize(1), obj.canvasSize(2), obj.totalFrames);
            stim(:, :, obj.preFrames+1:obj.preFrames+obj.stimFrames) = obj.amplitude;
        end

        function fName = getFileName(obj)
            if obj.baseIntensity == 0
                fName = 'intensity_inc_';
            elseif obj.contrast > 0
                fName = 'contrast_inc_';
            elseif obj.contrast < 0
                fName = 'contrast_dec_';
            end
            fName = [fName, fprintf('%up_%us_%ut.avi', 100*obj.contrast, obj.stimTime, obj.totalTime)];
        end
    end
end