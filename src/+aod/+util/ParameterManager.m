classdef ParameterManager < handle & matlab.mixin.CustomDisplay
% Manages the specification of expected parameters (HDF5 attributes)
%
% Parent:
%   handle, matlab.mixin.CustomDisplay
%
% Constructor:
%   obj = aod.util.ParameterManager()
%
% Properties:
%   ExpectedParameters
%   Count
%
% Methods:
%   add(obj, paramName, defaultValue, validationFcn, description)
%   remove(obj, paramName)
%   clear(obj)
%
%   ip = getParser(obj)
%   ip = parse(obj, varargin)
%   [tf, idx] = hasParam(obj, paramName)
%
% Overloaded methods:
%   tf = isempty(obj)
%   tf = isequal(obj, other)
%   T = table(obj)
%
% See also:
%   aod.util.ExpectedParameter, aod.util.Parameters

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ExpectedParameters          % aod.util.templates.ExpectedParameter
    end

    properties (Dependent)
        Count
    end

    methods 
        function obj = ParameterManager()
            % Do nothing
        end
        
        function out = get.Count(obj)
            if isempty(obj.ExpectedParameters)
                out = 0;
            else
                out = numel(obj.ExpectedParameters);
            end
        end

    end

    methods
        function add(obj, param, defaultValue, validationFcn, description)
            % Add a new expected parameter
            %
            % Syntax:
            %   add(obj, name)
            %   add(obj, name, defaultValue, validationFcn, description)
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

            arguments
                obj
                param               
                defaultValue                    = []
                validationFcn                   = []
                description         string      = string.empty()
            end

            % Single inputs can be ExpectedParameter or ParameterManager
            if nargin == 2
                if isa(param, 'aod.util.templates.ExpectedParameter')
                    if any(isequal(param, obj.ExpectedParameters))
                        error('add:ParameterExists',...
                            'A parameter already exists named %s', param.Name);     
                    end
                    obj.ExpectedParameters = cat(1, obj.ExpectedParameters, param);
                    return
                elseif isa(param, 'aod.util.ParameterManager')
                    PM = param;
                    for i = 1:numel(PM.ExpectedParameters)
                        obj.add(PM.ExpectedParameters(i));
                    end
                    return
                end
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
            % Remove a parameter by name
            %
            % Syntax:
            %   remove(obj, paramName)
            %
            % Inputs:
            %   paramName           string/char
            %       Parameter name to remove
            %
            % Examples:
            %   PM = aod.util.ParameterManager();
            %   PM.add('MyParam', [], @(x) ischar(x), 'A parameter');
            %   PM.remove('MyParam');
            % ----------------------------------------------------------

            if isempty(obj.ExpectedParameters)
                return
            end

            [~, idx] = obj.hasParam(paramName);
            if isempty(idx)
                warning('remove:ParamNotFound', 'Parameter %s not found', paramName);
            else
                obj.ExpectedParameters(idx) = [];
            end
        end

        function clear(obj)
            % Clear all parameters
            %
            % Syntax:
            %   clear(obj)
            % ----------------------------------------------------------
            obj.ExpectedParameters = [];
        end
    end

    methods
        function [tf, idx] = hasParam(obj, paramName)
            % Check whether parameter exists and optionally, get index
            %
            % Syntax:
            %   [tf, idx] = hasParam(obj, paramName)
            % ----------------------------------------------------------

            if isempty(obj.ExpectedParameters)
                tf = false;
                return
            end
            
            paramName = convertCharsToStrings(paramName);

            allParamNames = arrayfun(@(x) string(x.Name), obj.ExpectedParameters);

            idx = find(allParamNames == paramName);
            tf = ~isempty(idx);
        end
        
        function ip = getParser(obj)
            % Populate an inputParser with parameters
            %
            % Syntax:
            %   ip = getParser(obj)
            % ----------------------------------------------------------

            ip = aod.util.InputParser;
            for i = 1:numel(obj.ExpectedParameters)
                ip = addToParser(obj.ExpectedParameters(i), ip);
            end
        end

        function ip = parse(obj, varargin)
            % Create inputParser and parse variable input
            %
            % Syntax:
            %   ip = parse(obj, varargin)
            % ----------------------------------------------------------

            ip = obj.getParser();
            parse(ip, varargin{:});
        end
    end
    
    % matlab.mixin.CustomDisplay methods
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
                    value = "Default = ";
                    if isempty(obj.ExpectedParameters(i).Default)
                        value = value + "[]";
                    else
                        value = value + strtrim(formattedDisplayText(obj.ExpectedParameters(i).Default));
                    end
                    value = value + ", Validation = ";
                    if isempty(obj.ExpectedParameters(i).Validation)
                        value = value + "[]";
                    else
                        value = value + strtrim(formattedDisplayText(obj.ExpectedParameters(i).Validation));
                    end
                    value = value + ", Description = ";
                    if isempty(obj.ExpectedParameters(i).Description)
                        value = value + "[]";
                    else
                        value = value + obj.ExpectedParameters(i).Description;
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

        function tf = isequal(obj, other)
            if ~isa(other, 'aod.util.ParameterManager')
                tf = false;
                return
            end

            if obj.Count ~= other.Count 
                tf = false;
                return 
            end

            for i = 1:obj.Count 
                iParam = obj.ExpectedParameters(i);
                [tfParam, idx] = other.hasParam(iParam.Name);
                if ~tfParam
                    tf = false; 
                    return
                end
                oParam = other.ExpectedParameters(idx);
                if any([isempty(iParam.Validation), isempty(oParam.Validation)])
                    if ~isequal(iParam.Validation, oParam.Validation)
                        disp(iParam.Name)
                        tf = false;
                        return
                    end
                end
                
                if any([isempty(iParam.Default), isempty(oParam.Default)])
                    if ~isequal(iParam.Default, oParam.Default)
                        disp(['Default - ', iParam.Name])
                        tf = false;
                        return
                    end
                end

                
                if any([isempty(iParam.Description), isempty(oParam.Description)])
                    if ~isequal(iParam.Description, oParam.Description)
                        disp(['Description - ', iParam.Name])
                        tf = false;
                        return
                    end
                end
            end
            tf = true;
        end
        
        function T = table(obj)
            if isempty(obj)
                T = [];
                return
            end
        
            names = repmat("", [obj.Count, 1]);
            defaults = repmat("[]", [obj.Count, 1]);
            validations = repmat("[]", [obj.Count, 1]);
            descriptions = repmat("[]", [obj.Count, 1]);

            for i = 1:obj.Count
                EP = obj.ExpectedParameters(i);

                names(i) = EP.Name;

                if ~isempty(EP.Default)
                    defaults(i) = value2string(EP.Default);
                end

                if ~isempty(EP.Validation)
                    validations(i) = value2string(EP.Validation);
                end

                if ~isempty(EP.Description)
                    descriptions(i) = EP.Description;
                end
            end

            T = table(names, defaults, validations, descriptions,...
                'VariableNames', ["Name", "Default", "Validation", "Description"]);
        end
    end
end 