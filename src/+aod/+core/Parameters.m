classdef Parameters < containers.Map & matlab.mixin.CustomDisplay 
% PARAMETERS
%
% Description:
%   Wrapper for containers.Map with detailed contents display
%
% Constructor:
%   obj = aod.core.Parameters(keySet, valueSet)
%   obj = aod.core.Parameters('KeyType', kType, 'ValueType', vType)
%
% See also:
%   containers.Map
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
                header = sprintf('\t%s',headerStr);
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