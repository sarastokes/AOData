classdef Entry < handle
% Represents the specifications for a single entry (aka property)
%
% Constructor:
%   obj = aod.specification.Entry(prop, varargin)
%
% Inputs:
%   prop        string, char or meta.property
%       The dataset or attribute
% Optional key/value inputs:
%   Size                    string or double
%   Class                   string
%   Default
%   Functions               cell of function handles
%   Description             string
%   Units                   string
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events
        LoggableEvent
    end

    properties (SetAccess = private)
        Name            (1,1)     string
        Size                      aod.specification.Size
        Class           (1,1)     aod.schema.validators.Class
        Default         (1,1)     aod.specification.DefaultValue
        Functions       (1,1)     aod.specification.ValidationFunction
        Description               aod.schema.decorators.Description
        Units           (1,:)     string = string.empty(1,0)
    end

    properties (Access = private)
        listeners                 event.listener
    end

    properties (Hidden, Constant)
        FIELDS = ["size", "class", "default", "function", "description", "units"];
    end

    methods
        function obj = Entry(prop, varargin)
            % Defaults (prevents issues w/ instantiation in property block)
            obj.Size = aod.schema.validators.Size([]);
            obj.Class = aod.schema.validators.Class([]);
            obj.Default = aod.specification.DefaultValue([]);
            obj.Description = aod.schema.decorators.Description([]);
            obj.Functions = aod.specification.ValidationFunction([]);

            obj.bind();

            if nargin == 0
                return
            end

            % Initialize from meta.property
            if isa(prop, 'meta.property')
                obj.Name = prop.Name;
                arrayfun(@(x) obj.parse(x, prop), obj.FIELDS);
                obj.checkIntegrity();
                return
            end

            % Initialize from user-defined inputs
            obj.setName(prop);

            % Parse additional specifications
            ip = obj.getParser(varargin{:});
            arrayfun(@(x) obj.parse(x, ip.Results.(x)), string(ip.Parameters));
            obj.checkIntegrity();
        end
    end

    methods
        function assign(obj, varargin)
            ip = obj.getParser(varargin{:});

            % Only pass the values user provided
            changedProps = setdiff(ip.Parameters, ip.UsingDefaults);
            cellfun(@(x) obj.parse(x, ip.Results.(x)), changedProps);
            obj.checkIntegrity();
        end

        function [tf, ME] = validate(obj, input)
            [tf1, ME1] = obj.Size.validate(input);
            [tf2, ME2] = obj.Class.validate(input);
            [tf3, ME3] = obj.Functions.validate(input);
            % Determine whether all tests were passed
            tf = all([tf1, tf2, tf3]);
            % Combine exceptions, if present
            ME = [ME1, ME2, ME3];
        end

        function out = text(obj)
            out = obj.Name + newline;
            out = out + sprintf("\tDescription:\t%s", obj.Description.text()) + newline;
            out = out + sprintf("\tClass:\t\t\t%s", obj.Class.text()) + newline;
            out = out + sprintf("\tSize:\t\t\t%s", obj.Size.text()) + newline;
            out = out + sprintf("\tValidators:\t\t%s", obj.Functions.text()) + newline;
            out = out + sprintf("\tDefault:\t\t%s", obj.Default.text()) + newline;
            if isempty(obj.Units)  % TODO
                out = out + sprintf("\tUnits:\t\t\t%s", "[]") + newline;
            else
                out = out + sprintf("\tUnits:\t\t\t%s", obj.Units) + newline;
            end
        end

        function out = code(obj)
            out = sprintf('value.set("%s"', obj.Name);
            if ~isempty(obj.Class)
                out = appendParam(out);
                out = out + sprintf('"Class", %s', obj.Class.jsonencode());
            end
            if ~isempty(obj.Size)
                out = appendParam(out);
                out = out + sprintf('"Size", %s', obj.Size.jsonencode());
            end
            if ~isempty(obj.Default)
                out = appendParam(out);
                out = out + sprintf('"Default", %s', obj.Default.jsonencode());
            end
            if ~isempty(obj.Functions)
                out = appendParam(out);
                out = out + sprintf('"Functions", %s', obj.Functions.text());
            end
            if ~isempty(obj.Description)
                out = appendParam(out);
                out = out + sprintf('"Description", %s', obj.Description.jsonencode());
            end
            if ~isempty(obj.Units)
                out = appendParam(out);
                out = out + sprintf('"Units", "%s"', obj.Units);
            end
            out = out + sprintf(');') + newline;

            function txt = appendParam(input)
                txt = input + ",..." + newline + "    ";
            end
        end

        function tf = isSpecified(obj)
            tf = true;
            % tf = [isempty(obj.Class), isempty(obj.Size),...
            %     isempty(obj.Default), isempty(obj.Units),...
            %     isempty(obj.Functions), isempty(obj.Description)];
        end

        function details = compare(obj, other)
            arguments
                obj
                other           aod.specification.Entry
            end

            details = aod.common.KeyValueMap();
            details('Description') = obj.Description.compare(other.Description);
            details('Size') = obj.Size.compare(other.Size);
            details('Class') = obj.Class.compare(other.Class);
            details('Functions') = obj.Functions.compare(other.Functions);
            details('Default') = obj.Default.compare(other.Default);
        end
    end

    % Setters
    methods
        function setName(obj, name)
            if ~isvarname(name)
                error('setName:InvalidName',...
                    '%s is not a valid MATLAB variable name', name);
            end
            obj.Name = name;
        end

        function setDescription(obj, input)
            obj.Description.setValue(input);
            obj.checkIntegrity();
        end

        function setClass(obj, input)
            obj.Class.setValue(input);
            obj.checkIntegrity();
        end

        function setSize(obj, input)
            obj.Size.setValue(input);
            obj.checkIntegrity();
        end

        function setFunctions(obj, input)
            obj.Functions.setValue(input);
            obj.checkIntegrity();
            obj.extractFromFunctions();
        end

        function setDefault(obj, input)
            obj.Default.setValue(input);
            obj.checkIntegrity();
        end

        function setUnits(obj, input)
            input = convertCharsToStrings(input);
            if ~isa(input, 'meta.property')
                obj.Units = input;
            end
        end
    end

    % Getters
    methods
        function [fcnHandle, validators] = getFullValidation(obj)
            % Combine validators and class type into fcn handles
            %
            % Syntax:
            %   fcnHandle = getFullValidation(obj)
            % -------------------------------------------------------------

            if isempty(obj.Class)
                classFcn = {};
            else
                eval(sprintf("classFcn = @(x) aod.util.isa(x, %s);", ...
                    value2string(obj.Class.text())));
            end

            if isempty(obj.Functions)

                if ~isempty(classFcn)
                    validators = classFcn;
                else
                    validators = [];
                    return
                end

            else
                validators = cat(2, obj.Functions.Value, {classFcn});
            end

            fcnHandle = aod.specification.util.combineFunctionHandles(validators);
        end
    end

    methods (Access = private)
        function parse(obj, specType, specValue)
            arguments
                obj
                specType        char
                specValue
            end

            switch lower(specType)
                case 'size'
                    obj.setSize(specValue);
                case 'function'
                    obj.setFunctions(specValue);
                case 'class'
                    obj.setClass(specValue);
                case 'default'
                    obj.setDefault(specValue);
                case 'description'
                    obj.setDescription(specValue);
                case 'units'
                    obj.setUnits(specValue);
                otherwise
                    error('parse:InvalidSpecificationType',...
                        'Specification type must be size, function class, default or description');
            end
        end

        function checkIntegrity(obj)
            if aod.util.isempty(obj.Default)
                return
            end

            % Is default value the correct size?
            obj.Size.validate(obj.Default.Value);

            % Is default value of the appropriate class?
            if ~isempty(obj.Class)
                obj.Class.validate(obj.Default.Value);
            end

            % Does default value pass the validation functions
            if ~isempty(obj.Functions)
                tf = obj.Functions.validate(obj.Default.Value);
                if ~tf
                    error('checkIntegrity:DefaultValueDoesNotValidate',...
                        'The default value did not pass the validation')
                end
            end
        end

        function extractFromFunctions(obj)
            if isempty(obj.Functions)
                return
            end
            fcnText = obj.Functions.text();
            if contains(fcnText, "mustBeScalarOrEmpty")
                obj.setSize([1, 1]);
            elseif contains(fcnText, "mustBeText")
                obj.setClass("string, char");
                if contains(fcnText, "mustBeTextScalar")
                    obj.setSize("(1,:)");
                end
            elseif contains(fcnText, "mustBeNonzeroLengthText")
                obj.setClass("string, char");
            end
        end
    end

    methods (Access = private)
        function bind(obj)
            obj.listeners = addlistener(obj.Size,...
                "ValidationFailed", @obj.onValidationFailed);
            obj.listeners = cat(1, obj.listeners,...
                addlistener(obj.Class, "ValidationFailed", @obj.onValidationFailed));
            obj.listeners = cat(1, obj.listeners,...
                addlistener(obj.Functions, "ValidationFailed", @obj.onValidationFailed));
        end

        function onValidationFailed(obj, ~, evt)
            evt.assignPropName(obj.Name);
            notify(obj, "LoggableEvent");
        end
    end

    methods (Static, Access = private)
        function ip = getParser(varargin)
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Size', []);
            addParameter(ip, 'Description', "");
            addParameter(ip, 'Class', []);
            addParameter(ip, 'Function', {});
            addParameter(ip, 'Default', []);
            addParameter(ip, 'Units', "none");
            parse(ip, varargin{:});
        end
    end

    % MATLAB builtin methods
    methods
        function P = struct(obj)
            P = struct();
            P.Name = obj.Name;
            P.Size = obj.Size.jsonencode();
            P.Default = obj.Default.jsonencode();
            P.Class = obj.Class.jsonencode();
            P.Description = obj.Description.jsonencode();
            P.Function = obj.Functions.jsonencode();
        end
    end
end