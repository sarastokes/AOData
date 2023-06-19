classdef AttributeManager < handle & matlab.mixin.CustomDisplay
% Manages the specification of expected attributes (HDF5 attributes)
%
% Parent:
%   handle, matlab.mixin.CustomDisplay
%
% Constructor:
%   obj = aod.util.AttributeManager()
%
% Properties:
%   ExpectedAttributes
%   Count
%
% Methods:
%   add(obj, paramName, defaultValue, validationFcn, description)
%   remove(obj, paramName)
%   clear(obj)
%
%   ip = getParser(obj)
%   ip = parse(obj, varargin)
%   [tf, idx] = hasAttr(obj, paramName)
%
% Overloaded methods:
%   tf = isempty(obj)
%   tf = isequal(obj, other)
%   T = table(obj)
%
% See also:
%   aod.util.ExpectedAttribute, aod.common.KeyValueMap

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ExpectedAttributes          % aod.util.templates.ExpectedAttribute
    end

    properties (Dependent)
        Count
    end

    methods 
        function obj = AttributeManager()
            % Do nothing
        end
        
        function out = get.Count(obj)
            if isempty(obj.ExpectedAttributes)
                out = 0;
            else
                out = numel(obj.ExpectedAttributes);
            end
        end
    end

    methods
        function p = get(obj, paramName, errorType)
            % Get an ExpectedAttribute, if it exists
            %
            % Syntax:
            %   p = get(obj, paramName)
            % -------------------------------------------------------------

            import aod.infra.ErrorTypes 

            if nargin < 3
                errorType = ErrorTypes.WARNING;
            else
                errorType = ErrorTypes.init(errorType);
            end

            [tf, idx] = obj.hasAttr(paramName);

            if tf 
                p = obj.ExpectedAttributes(idx);
            else
                p = [];
                switch errorType 
                    case ErrorTypes.ERROR 
                        error('get:AttributeNotFound',...
                            'Attribute named %s does not exist', paramName);
                    case ErrorTypes.WARNING
                        warning('get:AttributeNotFound',...
                            'Attribute named %s does not exist', paramName);
                end
            end
        end

        function add(obj, attr, defaultValue, validationFcn, description)
            % Add a new expected attribute
            %
            % Syntax:
            %   add(obj, name)
            %   add(obj, name, defaultValue, validationFcn, description)
            % 
            % Inputs:
            %   attr       char, ExpectedAttribute, AttributeManager
            %       Attribute name or attribute class
            %
            % Examples:
            %   % ExpectedAttribute and AttributeManager as a single input
            %   expParam = aod.util.ExpectedAttribute('MyParam');
            %   obj.add(expParam)
            %
            %   % Add a new attribute by components (2-4 are optional)
            %   obj.add('MyParam', [], @(x) ischar(x), 'A attribute');
            % -------------------------------------------------------------

            arguments
                obj
                attr               
                defaultValue                    = []
                validationFcn                   = []
                description         string      = string.empty()
            end

            % Single inputs can be ExpectedAttribute or AttributeManager
            if nargin == 2
                if isa(attr, 'aod.util.templates.ExpectedAttribute')
                    if any(isequal(attr, obj.ExpectedAttributes))
                        error('add:AttributeExists',...
                            'A attribute already exists named %s, use remove first', attr.Name);     
                    end
                    obj.ExpectedAttributes = cat(1, obj.ExpectedAttributes, attr);
                    return
                elseif isa(attr, 'aod.util.AttributeManager')
                    PM = attr;
                    for i = 1:numel(PM.ExpectedAttributes)
                        obj.add(PM.ExpectedAttributes(i));
                    end
                    return
                end
            end
            
            newParam = aod.util.templates.ExpectedAttribute(...
                attr, defaultValue, validationFcn, description);

            % Confirm 
            if any(isequal(newParam, obj.ExpectedAttributes))
                error('add:AttributeExists',...
                    'A attribute already exists named %s', newParam.Name);
            end
            obj.ExpectedAttributes = cat(1, obj.ExpectedAttributes, newParam);
        end

        function remove(obj, paramName)
            % Remove a attribute by name
            %
            % Syntax:
            %   remove(obj, paramName)
            %
            % Inputs:
            %   paramName           string/char
            %       Attribute name to remove
            %
            % Examples:
            %   PM = aod.util.AttributeManager();
            %   PM.add('MyParam', [], @(x) ischar(x), 'A attribute');
            %   PM.remove('MyParam');
            % ----------------------------------------------------------

            if isempty(obj.ExpectedAttributes)
                return
            end

            [~, idx] = obj.hasAttr(paramName);
            if isempty(idx)
                warning('remove:ParamNotFound', 'Attribute %s not found', paramName);
            else
                obj.ExpectedAttributes(idx) = [];
            end
        end

        function clear(obj)
            % Clear all attributes
            %
            % Syntax:
            %   clear(obj)
            % ----------------------------------------------------------
            obj.ExpectedAttributes = [];
        end
    end

    methods
        function attrNames = list(obj)
            if isempty(obj)
                attrNames = [];
            else
                attrNames = string(aod.util.arrayfun(@(x) x.Name, obj.ExpectedAttributes));
            end
        end

        function [tf, idx] = hasAttr(obj, paramName)
            % Check whether attribute exists and optionally, get index
            %
            % Syntax:
            %   [tf, idx] = hasAttr(obj, paramName)
            % ----------------------------------------------------------

            if isempty(obj.ExpectedAttributes)
                tf = false; idx = [];
                return
            end
            
            paramName = convertCharsToStrings(paramName);

            allParamNames = arrayfun(@(x) string(x.Name), obj.ExpectedAttributes);

            idx = find(allParamNames == paramName);
            tf = ~isempty(idx);
        end
        
        function ip = getParser(obj)
            % Populate an inputParser with attributes
            %
            % Syntax:
            %   ip = getParser(obj)
            % ----------------------------------------------------------

            ip = aod.util.InputParser;
            for i = 1:numel(obj.ExpectedAttributes)
                ip = addToParser(obj.ExpectedAttributes(i), ip);
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
            if ~isscalar(obj)
                header  = getHeader@matlab.mixin.CustomDisplay(obj);
            else
                headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                headerStr = sprintf('%s with %u attributes:',... 
                    headerStr, numel(obj.ExpectedAttributes));
                header = sprintf('  %s',headerStr);
            end
        end

        function propgrp = getPropertyGroups(obj)
            if ~isscalar(obj)
                propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else                
                propList = struct();

                for i = 1:numel(obj.ExpectedAttributes)
                    value = "Default = ";
                    if isempty(obj.ExpectedAttributes(i).Default)
                        value = value + "[]";
                    else
                        value = value + strtrim(formattedDisplayText(obj.ExpectedAttributes(i).Default));
                    end
                    value = value + ", Validation = ";
                    if isempty(obj.ExpectedAttributes(i).Validation)
                        value = value + "[]";
                    else
                        value = value + strtrim(formattedDisplayText(obj.ExpectedAttributes(i).Validation));
                    end
                    value = value + ", Description = ";
                    if isempty(obj.ExpectedAttributes(i).Description)
                        value = value + "[]";
                    else
                        value = value + obj.ExpectedAttributes(i).Description;
                    end
                    propList.(obj.ExpectedAttributes(i).Name) = value;
                end
                propgrp = matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end

    % Builtin methods
    methods
        function tf = isempty(obj)
            if ~isscalar(obj)
                tf = arrayfun(@(x) isempty(x), obj);
                return
            end
            tf = obj.Count > 0;
        end

        function tf = isequal(obj, other)
            if ~isa(other, 'aod.util.AttributeManager')
                tf = false;
                return
            end

            if obj.Count ~= other.Count 
                tf = false;
                return 
            end

            for i = 1:obj.Count 
                iParam = obj.ExpectedAttributes(i);
                [tfParam, idx] = other.hasAttr(iParam.Name);
                if ~tfParam
                    tf = false; 
                    return
                end
                oParam = other.ExpectedAttributes(idx);
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
                EP = obj.ExpectedAttributes(i);

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