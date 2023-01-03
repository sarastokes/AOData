classdef Parameters < containers.Map & matlab.mixin.CustomDisplay 
% PARAMETERS
%
% Description:
%   Wrapper for containers.Map with detailed contents display
%
% Parent:
%   containers.Map, matlab.mixin.CustomDisplay
%
% Constructor:
%   obj = aod.util.Parameters(keySet, valueSet)
%
% Methods:
%   out = toMap(obj)
%       Convert back to containers.Map
% All other methods and properties are identical to containers.Map
%
% See Also:
%   containers.Map

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Parameters(varargin)
            obj = obj@containers.Map(varargin{:});
        end

        function out = toMap(obj)
            % Convert to a containers.Map object
            %
            % Syntax:
            %   out = toMap(obj)
            % -------------------------------------------------------------
            out = containers.Map();
            k = obj.keys;
            v = obj.values;

            if isempty(k)
                return
            end

            for i = 1:numel(k)
                out(k{i}) = v{i};
            end
        end
    end

    % matlab.mixin.CustomDisplay
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