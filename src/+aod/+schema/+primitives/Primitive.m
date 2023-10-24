classdef (Abstract) Primitive < handle & matlab.mixin.Heterogeneous & matlab.mixin.CustomDisplay
% PRIMITIVE (abstract)
%
% Superclasses:
%   handle, matlab.mixin.Heterogeneous, matlab.mixin.CustomDisplay
%
% Constructor:
%   obj = aod.specification.Primitive(name, varargin)

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (SetAccess = private)
        Parent                  aod.specification.Entry
        Name        (1,1)       string
        Default     (1,1)       aod.specification.DefaultValue
        Format      (1,1)       aod.specification.MatlabClass
        Description (1,1)       aod.specification.Description
        Size                    aod.specification.Size
    end

    properties (Hidden, SetAccess = protected)
        % Determines which aspects of an AOData entity the primitive can
        % be used to describe. Some may not be valid for attributes.
        ALLOWABLE_PARENT_TYPES = ["Dataset", "Attribute"];
    end

    properties (Abstract, Hidden, SetAccess = protected)
        % These are the fields users can set with key/value inputs.
        % They are assigned in the order listed, so one option can be
        % used to validate or assign values to a later option.
        OPTIONS     (1,:)       string
        % These are the fields that will be used to validate data. This may
        % differ from OPTIONS which can contain decorators and validators
        % that are set automatically and thus absent fromm OPTIONS.
        VALIDATORS  (1,:)       string
        % The primitive type
        PRIMITIVE_TYPE          aod.schema.primitives.PrimitiveTypes
    end

    methods
        function obj = Primitive(name, parent)
            if nargin < 1
                name = "UNDEFINED";
            end
            obj.setName(name);

            if nargin > 1
                obj.setParent(parent);
            end

            % Initialize
            obj.Size = aod.specification.Size([], obj);
            obj.Format = aod.specification.MatlabClass([], obj);
            obj.Default = aod.specification.DefaultValue([], obj);
            obj.Description = aod.specification.Description([], obj);
        end

        function tf = isValid(obj)
            tf = aod.util.isempty(obj.Name) || strcmp(obj.Name, "UNDEFINED");
            try
                obj.checkIntegrity();
            catch ME
                if contains(ME.identifier, "checkIntegrity")
                    tf = false;
                    warning("isValid:IntegrityFailure", "%s", ME.message);
                else
                    rethrow(ME);
                end
            end
        end

        function displayOptions(obj)
            disp(obj.OPTIONS);
        end
   end

    methods %(Sealed)
        function assign(obj, varargin)
            % Assign specifications with key/value inputs
            %
            % Syntax:
            %   assign(obj, varargin)
            %
            % Note:
            %   The specific keys accepted are defined by each subclass in
            %   the "OPTIONS" property, then passed through inputParser
            % -------------------------------------------------------------
            ip = obj.getParser();
            try
                parse(ip, varargin{:});
            catch ME
                if strcmp(ME.identifier, 'MATLAB:InputParser:UnmatchedParameter')
                    % Customize error message to provide more guidance
                    % TODO: Get parent if available
                    error("assign:InvalidParameter",...
                        '%sValid parameters for %s are:  %s',...
                        extractBefore(ME.message, "For a list of valid"),...
                        upper(getClassWithoutPackages(obj)),...
                        strjoin(ip.Parameters, ', '));
                else
                    rethrow(ME);
                end
            end

            % Only pass the values user provided
            changedProps = setdiff(ip.Parameters, ip.UsingDefaults);
            cellfun(@(x) obj.parse(x, ip.Results.(x)), changedProps);
            obj.checkIntegrity();
        end

        function S = toYAML(obj)
            % Create a structure prepped for writing to a YAML file
            %
            % Syntax:
            %   S = toYAML(obj)
            % ----------------------------------------------------------
            S.(obj.Name) = struct();

            currentProps = string(properties(obj));
            for i = 1:numel(currentProps)
                iProp = currentProps(i);
                if isSubclass(obj.(iProp), 'aod.specification.Specification')
                    S.(obj.Name).(iProp) = obj.(iProp).getValueForYAML();
                end
            end
        end
    end

    methods (Sealed)
        function setName(obj, name)
            % Set the primitive's name, ensuring valid variable name
            %
            % Syntax:
            %   setName(obj, name)
            %
            % See also:
            %   isvarname
            % -------------------------------------------------------------
            arguments
                obj
                name    (1,1)       string
            end

            if ~isvarname(name)
                error('setName:InvalidName',...
                    'Property names must be valid MATLAB variables');
            end
            obj.Name = name;
        end

        function setDescription(obj, description)
            % Set the description of the dataset/property.
            %
            % Syntax:
            %   obj.setDescription(description)
            %
            % Inputs:
            %   description     string (1,1)
            %       Description of the dataset/property.
            % ----------------------------------------------------------
            obj.Description.setValue(description);
        end
    end

    methods
        function setDefault(obj, value)
            % Set the default value
            %
            % Syntax:
            %   setDefault(obj, value)
            % ----------------------------------------------------------
            if isempty(value)
                obj.Default.setValue([]);
            end

            obj.Default.setValue(value);
        end

        function setSize(obj, value)
            % Set the size of the number.
            %
            % Syntax:
            %   setSize(obj, value)
            %
            % See also:
            %   aod.specification.Size
            % ----------------------------------------------------------
            obj.Size = aod.specification.Size(value);
        end

        function setFormat(obj, value)
            obj.Format.setValue(value);
        end
    end

    methods (Sealed, Access = protected)
        function parse(obj, key, value)
            fcn = str2func("@(obj, x) set" + key + "(obj, x)");
            fcn(obj, value);
        end

        function parseInputs(obj, varargin)
            % Run only what is set in OPTIONS through custom inputParser
            % ----------------------------------------------------------
            ip = obj.getParser();
            parse(ip, varargin{:});

            for i = 1:numel(obj.OPTIONS)
                fcn = str2func("@(obj, x) set" + obj.OPTIONS(i) + "(obj, x)");
                fcn(obj, ip.Results.(obj.OPTIONS(i)));
            end
        end

        function ip = getParser(obj)
            % Create an inputParser dictated by the values in OPTIONS
            %
            % Notes:
            %   Parser isn't case-sensitive but partial-matching disabled
            % ----------------------------------------------------------
            ip = inputParser();
            ip.CaseSensitive = false;
            for i = 1:numel(obj.OPTIONS)
                ip.addParameter(obj.OPTIONS(i), []);
            end
        end
    end

    methods (Access = protected)
        function checkIntegrity(obj)
            if ~isempty(obj.Default)
                if ~isempty(obj.Size)
                    if ~obj.Size.validate(obj.Default.Value)
                        error('checkIntegrity:InvalidDefault',...
                            "Default is not the correct size: %s", obj.Size.text());
                    end
                end
                if ~isempty(obj.Format)
                    if ~obj.Format.validate(obj.Default.Value)
                        error('checkIntegrity:InvalidClass',...
                            "Default was class %s, but Format is %s", ...
                            class(obj.Default.Value), obj.Format.text());
                    end
                end
            end
        end
    end

    methods (Access = {?aod.specification.Entry, ?aod.schema.primitives.Primitive})
        function setParent(obj, parent)
            % Set the parent of the specification
            %
            % Syntax:
            %   setParent(obj, parent)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                arrayfun(@(x) x.setParent(obj), parent);
                return
            end

            mustBeA(parent, ["aod.specification.Entry", "aod.schema.primitives.Container"]);
            if isa(parent, 'aod.schema.primitives.Container')
                % Check if table is allowed, throw error if not

            end

            if isempty(parent)
                return
            end
            obj.Parent = parent;
        end
    end

    % matlab.mixin.CustomDisplay methods
    methods (Access = protected)
        function propgrp = getPropertyGroups(obj)
            propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);

            if ~isscalar(obj) || isempty(obj)
                return
            end


            f = fieldnames(propgrp.PropertyList);
            for i = 1:numel(f)
                propgrp.PropertyList.(f{i}) = convertProp(obj.(f{i}));
            end

            function out = convertProp(prop)
                if isa(prop, 'aod.specification.Size')
                    out = prop.text();
                elseif isa(prop, 'aod.specification.Specification')
                    out = prop.Value;
                else
                    out = prop;
                end
            end
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isequal(obj, other)
            % Determine if two primitives are equal
            %
            % Syntax:
            %   tf = isequal(obj, other)
            % -------------------------------------------------------------
            if ~isa(other, 'aod.schema.primitives.Primitive')
                tf = false;
                return
            end

            if ~isequal(obj.primitiveType, other.primitiveType)
                tf = false;
                return
            end

            for i = 1:numel(obj.OPTIONS)
                if ~isequal(obj.(obj.OPTIONS(i)), other.(obj.OPTIONS(i)))
                    tf = false;
                    return
                end
            end

            tf = true;  % At this point, they're equal.
        end
    end
end