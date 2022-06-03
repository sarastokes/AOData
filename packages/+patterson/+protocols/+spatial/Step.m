classdef Step < aod.builtin.protocols.SpatialProtocol
% CONTRASTSTEP
%
% Description:
%   A spatially-uniform change in intenstiy
%
% Constructor:
%   obj = patterson.protocols.spatial.step(stimTime, varargin)
%
% Inherited properties:
%   preTime
%   stimTime
%   tailTime
%   baseIntensity
%   contrast
%
% Inherited methods:
%   trace = temporalTrace(obj)
%   ...
% -------------------------------------------------------------------------
    methods
        function obj = Step(varargin)
            obj = obj@aod.builtin.protocols.SpatialProtocol(varargin{:});
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(obj.canvasSize(1), obj.canvasSize(2), obj.totalFrames);
            stim(:, :, obj.preFrames+1:obj.preFrames+obj.stimFrames) = obj.amplitude;
        end

        function fName = getFileName(obj)
            if obj.baseIntensity == 0
                fName = 'intensity_increment_';
            elseif obj.contrast > 0
                fName = 'contrast_increment_';
            elseif obj.contrast < 0
                fName = 'contrast_decrement_';
            end
            fName = [fName, fprintf('%up_%us_%ut.avi', 100*obj.contrast, obj.stimTime, obj.totalTime)];
        end
    end
end