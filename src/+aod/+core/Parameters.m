classdef Parameters < containers.Map & matlab.mixin.CustomDisplay 
% PARAMETERS
%
% Description:
%   Wrapper for containers.Map with detailed contents display
%
% Parent:
%   containers.Map
%   matlab.mixin.CustomDisplay
%
% Constructor:
%   obj = aod.core.Parameters(keySet, valueSet)
%
% Notes:
%   Use is identical to the containers.Map class
% -------------------------------------------------------------------------
    methods
        function obj = Parameters(varargin)
            obj = obj@containers.Map(varargin{:});
        end
    end

    methods (Access = protected)
        function header = getHeader(obj)
            if isempty(obj)
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            else
                headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                headerStr = [headerStr, ' with ', num2str(numel(obj.keys)), ' members:'];
                header = sprintf('  %s',headerStr);
            end
        end

        function propgrp = getPropertyGroups(obj)
            if isempty(obj)
                propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                keys = obj.keys;
                values = obj.values;
                propList = struct();
                for i = 1:numel(keys)
                    propList.(keys{i}) = values{i};
                end
                propgrp = matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end
end 