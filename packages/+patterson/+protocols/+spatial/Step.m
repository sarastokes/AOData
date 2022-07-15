classdef Step < aod.builtin.protocols.SpatialProtocol
% STEP
%
% Description:
%   A spatially-uniform change in intenstiy
%
% Constructor:
%   obj = patterson.protocols.spatial.Step(varargin)
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
% -------------------------------------------------------------------------

    methods
        function obj = Step(calibration, varargin)
            obj = obj@aod.builtin.protocols.SpatialProtocol(calibration, varargin{:});
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(obj.canvasSize(1), obj.canvasSize(2), obj.totalFrames);
            stim(:, :, obj.preFrames+1:obj.preFrames+obj.stimFrames) = obj.amplitude;
        end

        function fName = getFileName(obj)
            [a, b] = parseModulation(obj.baseIntenity, obj.contrast);
            fName = [sprintf('%s_%s_%up_%us_%ut', a, b,... 
                abs(100*obj.contrast), obj.stimTime, obj.totalTime)];
            if obj.tailTime == 0
                fName = ['step_', fName];
            end
        end
    end
end