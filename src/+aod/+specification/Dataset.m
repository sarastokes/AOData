classdef Dataset < handle 
% Represents the specifications for a single dataset (aka property)
%
% Constructor:
%   obj = aod.specification.Dataset(prop, varargin)
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events 
        LoggableEvent
    end

    properties (SetAccess = private)
        Name            (1,1)     string
        Size                      aod.specification.Size 
        Class           (1,1)     aod.specification.MatlabClass
        Default         (1,1)     aod.specification.DefaultValue
        Functions       (1,1)     aod.specification.ValidationFunction
        Description               aod.specification.Description 
        Units           (1,1)     string        % For now
    end

    properties (Access = private)
        listeners                 event.listener 
    end

    properties (Hidden, Constant)
        FIELDS = ["size", "class", "default", "function", "description", "units"];
    end

    methods
        function obj = Dataset(prop, varargin)
            % Defaults (prevents issues w/ instantiation in property block)
            obj.Size = aod.specification.Size([]); 
            obj.Class = aod.specification.MatlabClass([]);
            obj.Default = aod.specification.DefaultValue([]);
            obj.Description = aod.specification.Description([]);
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
            obj.Name = prop;

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

        function tf = validate(obj, input)
            tf1 = obj.Size.validate(input);
            tf2 = obj.Class.validate(input);
            tf3 = obj.Functions.validate(input);
            tf = all([tf1, tf2, tf3]);
        end

        function out = text(obj)

            out = "Name: " + obj.Name + newline;
            out = out + "    Description: " + obj.Description.text() + newline;
            out = out + "    Class: " + obj.Class.text() + newline;
            out = out + "    Size: " + obj.Size.text() + newline;
            out = out + "    Validators: " + obj.Functions.text() + newline;
            out = out + "    Default: " + obj.Default.text() + newline;
        end
    end

    % Setters
    methods
        function setName(obj, name)
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
                    % Leave alone for now
                otherwise
                    error('Dataset:InvalidType',...
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