classdef Step < sara.protocols.spatial.Pulse
% STEP
%
% Description:
%   A step up or down in intensity
%
% Parent:
%   sara.protocols.spatial.Pulse
%
% Constructor:
%   obj = Step(calibration, varargin)
%
% Inherited properties:
%   preTime
%   stimTime                
%   tailTime                fixed at 0
%   contrast                
%   baseIntensity           
%
% Notes:
%   Specialized version of Pulse, separated for clarity
% -------------------------------------------------------------------------
    
    methods
        function obj = Step(calibration, varargin)
            obj = obj@sara.protocols.spatial.Pulse(...
                calibration, varargin{:});

            % Input checking
            if obj.baseIntensity ~= 0 && obj.contrast ~= -1
                error('STEP: Not implemented for lights up/down');
            end
            
            % Overwrites
            if obj.tailTime > 0
                warning('Step protocol sets tailTime = 0');
                obj.tailTime = 0;
            end
        end

        function fName = getFileName(obj)
            if obj.baseIntensity == 0
                fName = sprintf('lights_on_%up_%ut',...
                    100*obj.contrast, obj.totalTime);
            else
                fName = sprintf('lights_off_%up_%ut',...
                    100*obj.baseIntensity, obj.totalTime);
            end
        end
    end
end