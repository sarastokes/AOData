classdef ParameterManager < handle & matlab.mixin.CustomDisplay
% Manages the specification of expected parameters (HDF5 attributes)
%
% Parent:
%   handle, matlab.mixin.CustomDisplay
%
% Constructor:
%   obj = aod.util.ParameterManager()
%
% See also:
%   aod.util.ExpectedParameter, aod.util.Parameter

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ExpectedParameters          % aod.util.template.ExpectedParameter
    end

    methods 
        function obj = ParameterManager()
            % Do nothing
        end

        function add(obj, param, defaultValue, validationFcn, description)
            % Add a new expected parameter
            %
            % Syntax:
            %   add(obj, param)
            %   add(obj, param, defaultValue, validationFcn, description)
            % 
            % Inputs:
            %   param       char, ExpectedParameter, ParameterManager
            %       Parameter name or parameter class
            %
            % Examples:
            %   % ExpectedParameter and ParameterManager as a single input
            %   expParam = aod.util.ExpectedParameter('MyParam');
            %   obj.add(expParam)
            %
            %   % Add a new parameter by components (2-4 are optional)
            %   obj.add('MyParam', [], @(x) ischar(x), 'A parameter');
            % -------------------------------------------------------------

            % Single inputs can be ExpectedParameter or ParameterManager
            if nargin == 2
                if isa(param, 'aod.util.templates.ExpectedParameter')
                    if isequal(param, obj.ExpectedParameters)
                        error('add:ParameterExists',...
                            'A parameter already exists named %s', param.Name);     
                    end
                    obj.ExpectedParameters = cat(1, obj.ExpectedParameters, param);
                    return
                elseif isa(param, 'ParameterManager')
                    PM = param;
                    for i = 1:numel(PM.ExpectedParameters)
                        obj.add(PM.ExpectedParameters(i));
                    end
                    return
                end
            end

            if nargin < 3
                defaultValue = [];
            end

            if nargin < 4
                validationFcn = [];
            end

            if nargin < 5
                description = [];
            end
            
            newParam = aod.util.templates.ExpectedParameter(param, defaultValue, validationFcn, description);

            % Confirm 
            if any(isequal(newParam, obj.ExpectedParameters))
                error('add:ParameterExists',...
                    'A parameter already exists named %s', newParam.Name);
            end
            obj.ExpectedParameters = cat(1, obj.ExpectedParameters, newParam);
        end

        function remove(obj, paramName)
            if isempty(obj.ExpectedParameters)
                return
            end

            idx = [];
            for i = 1:numel(obj.ExpectedParameters)
                if strcmpi(obj.ExpectedParameters(i).Name, paramName)
                    idx = 1;
                end
            end
            if isempty(idx)
                warning('remove:ParamNotFound', 'Parameter %s not found', paramName);
            else
                obj.ExpectedParameters(idx) = [];
            end
        end

        function clear(obj)
            obj.ExpectedParameters = [];
        end
    end

    methods
        function ip = parse(obj, varargin)
            ip = obj.getParser();
            parse(ip, varargin{:});
        end

        function ip = getParser(obj)
            ip = aod.util.InputParser;
            for i = 1:numel(obj.ExpectedParameters)
                ip = addToParser(obj.ExpectedParameters(i), ip);
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
                headerStr = sprintf('%s with %u parameters:',... 
                    headerStr, numel(obj.ExpectedParameters));
                header = sprintf('  %s',headerStr);
            end
        end

        function propgrp = getPropertyGroups(obj)
            if isempty(obj)
                propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else                
                propList = struct();

                for i = 1:numel(obj.ExpectedParameters)
                    if isempty(obj.ExpectedParameters(i).Default)
                        value = "Default = [], ";
                    else
                        value = sprintf("Default = %s, ",... 
                            strtrim(formattedDisplayText(obj.ExpectedParameters(i).Default)));
                    end
                    value = value + "Validation = ";
                    if isempty(obj.ExpectedParameters(i).Validation)
                        value = value + "[]";
                    else
                        value = value + strtrim(formattedDisplayText(obj.ExpectedParameters(i).Validation));
                    end
                    propList.(obj.ExpectedParameters(i).Name) = value;
                end
                propgrp = matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end

    % Builtin methods
    methods
        function tf = isempty(obj)
            tf = isempty(obj.ExpectedParameters);
        end
    end

end 