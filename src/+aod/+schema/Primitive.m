classdef (Abstract) Primitive < aod.schema.AODataSchemaObject & matlab.mixin.Heterogeneous & matlab.mixin.CustomDisplay
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
        Parent                  % aod.schema.Record, aod.schema.Container
        Required    (1,1)       logical = false
        Default     (1,1)       aod.schema.Default
        Class       (1,1)       aod.schema.validators.Class
        Description (1,1)       aod.schema.decorators.Description
        Size                    aod.schema.validators.Size
    end

    properties (Hidden, SetAccess = protected)
        SCHEMA_OBJECT_TYPE             = aod.schema.SchemaObjectTypes.PRIMITIVE
        % Determines which aspects of an AOData entity the primitive can
        % be used to describe. Some may not be valid for attributes and
        % almost all are not valid for files.
        ALLOWABLE_PARENT_TYPES = ["Dataset", "Attribute", "File"];
        % Holds integrity checks until object is constructed
        isInitializing  (1,1)   logical = true
        isContainer     (1,1)   logical = false
    end

    properties (Hidden, SetAccess = private)
        % Whether primitive is part of a Container subclass
        isNested        (1,1)   logical = false
    end

    properties (Dependent)
        SCHEMA_TYPE
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
        PRIMITIVE_TYPE          aod.schema.PrimitiveTypes
    end

    methods
        function obj = Primitive(parent)
            if nargin > 1
                obj.setParent(parent);
            end

            % Initialize
            obj.Size = aod.schema.validators.Size(obj, []);
            obj.Class = aod.schema.validators.Class(obj, []);
            obj.Default = aod.schema.Default(obj, []);
            obj.Description = aod.schema.decorators.Description(obj, []);
        end

        function value = get.SCHEMA_TYPE(obj)
            if obj.isNested
                value = aod.schema.SchemaTypes.ITEM_PRIMITIVE;
            else
                value = aod.schema.SchemaTypes.PRIMITIVE;
            end
        end
    end

    methods
        function parentObj = getParent(obj, parentType)
            arguments
                obj
                parentType      (1,1)       string      = ""
            end

            parentObj = obj.Parent;
            if isempty(parentObj) || parentType == ""
                return
            end

            switch lower(parentType)
                case "record"
                    parentClass = "aod.schema.Record";
                case "collection"
                    parentClass = "aod.schema.collections.RecordCollection";
                case "schema"
                    parentClass = "aod.schema.Schema";
                case "entity"
                    parentClass = "aod.common.Entity";
            end

            % Traverse hierarchy to match class
            while ~isSubclass(parentObj, parentClass)
                parentObj = parentObj.Parent;
                if isempty(parentObj)
                    break
                end
            end
        end

        function opts = getOptions(obj)
            % Required is always an option, others are subclass-specific
            opts = [obj.OPTIONS, "Required"];
            if nargout == 0
                disp(opts);
            end
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
    end

    methods
        function setDefault(obj, value)
            % Set the default value
            %
            % Syntax:
            %   setDefault(obj, value)
            % ----------------------------------------------------------
            if isempty(value) || (istable(value) && isempty(value.Properties.VariableNames))
                obj.Default.setValue([]);
            end

            obj.Default.setValue(value);
            obj.checkIntegrity(true);
        end

        function setSize(obj, value)
            % Set the size of the number.
            %
            % Syntax:
            %   setSize(obj, value)
            %
            % See also:
            %   aod.schema.validators.Size
            % --------------------------------------------------------------
            obj.Size.setValue(value);
            obj.checkIntegrity(true);
        end

        function setClass(obj, value)
            obj.Class.setValue(value);
            obj.checkIntegrity(true);
        end
    end

    methods (Sealed)
        function setRequired(obj, value)
            arguments
                obj
                value   (1,1)    logical
            end

            obj.Required = value;
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
            % --------------------------------------------------------------
            obj.Description.setValue(description);
        end
    end

    methods
        function [tf, ME, excObj] = checkIntegrity(obj, ~)
            excObj = aod.schema.exceptions.SchemaIntegrityException(obj);

            % These checks revolve around Default, skip if unset
            if obj.isInitializing || ~obj.Default.isSpecified()
                tf = true; ME = [];
                return
            end

            if obj.Size.isSpecified()
                if ~obj.Size.validate(obj.Default.Value)
                    excObj.addCause(MException('checkIntegrity:InvalidDefaultSize',...
                        "Default is not the correct size: %s", obj.Size.text()));
                end
            end
            if obj.Class.isSpecified()
                if ~obj.Class.validate(obj.Default.Value)
                    excObj.addCause(MException('checkIntegrity:InvalidDefaultClass',...
                        "Default was class %s, but Class is %s", ...
                        class(obj.Default.Value), obj.Class.text()));
                end
            end
            tf = ~excObj.hasErrors();
            ME = excObj.getException();
        end

        function [tf, ME, excObj] = validate(obj, value, errorType)
            arguments
                obj
                value
                errorType           = aod.infra.ErrorTypes.ERROR
            end

            errorType = aod.infra.ErrorTypes.init(errorType);
            excObj = aod.schema.exceptions.SchemaValidationException();

            tf = true;
            numFailures = 0;
            for i = 1:numel(obj.VALIDATORS)
                [itf, iME] = obj.(obj.VALIDATORS(i)).validate(value);
                if ~itf
                    tf = false;
                    numFailures = numFailures + 1;
                    excObj.addCause(iME, obj); % TODO Modify for Container
                    %MEs = cat(1, MEs, iME);
                end
            end

            ME = excObj.getException();
            if excObj.isValid()
                ME = [];
                return
            end

            % TODO Maybe a single function that gets called for this
            switch errorType
                case aod.infra.ErrorTypes.ERROR
                    throw(ME);
                case aod.infra.ErrorTypes.WARNING
                    throwWarning(ME);
            end
        end
    end

    methods (Sealed, Access = protected)
        function parse(obj, key, value)
            % Parse value for key, assuming key has a method starting with
            % the word "set" and ending with the key name.
            % ----------------------------------------------------------
            fcn = str2func("@(obj, x) set" + key + "(obj, x)");
            fcn(obj, value);
        end

        function parseInputs(obj, varargin)
            % Run only what is set in OPTIONS through custom inputParser
            % ----------------------------------------------------------
            ip = obj.getParser();
            parse(ip, varargin{:});
            % TODO: MATLAB:InputParser:ParamMissingValue

            opts = obj.getOptions();
            for i = 1:numel(opts)
                fcn = str2func("@(obj, x) set" + opts(i) + "(obj, x)");
                fcn(obj, ip.Results.(opts(i)));
            end
        end

        function ip = getParser(obj)
            % Create an inputParser dictated by the values in OPTIONS
            %
            % Notes:
            %   Parser isn't case-sensitive but partial-matching disabled
            % -------------------------------------------------------------

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.PartialMatching = false;
            for i = 1:numel(obj.OPTIONS)
                ip.addParameter(obj.OPTIONS(i), []);
            end
            ip.addParameter('Required', false, @islogical);
        end
    end

    methods (Access = {?aod.schema.Primitive})
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

            if aod.util.isempty(parent)
                obj.Parent = [];
                return
            end

            mustBeSubclass(parent, ["aod.schema.Record", "aod.schema.Container"]);
            if isa(parent, 'aod.schema.Container')
                % Check if table is allowed, throw error if not
                obj.isNested = true;
            else
                obj.isNested = false;
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
                if isa(prop, 'aod.schema.validator.Size')
                    out = prop.text();
                elseif isa(prop, 'aod.schema.Specification')
                    out = prop.Value;
                else
                    out = prop;
                end
            end
        end
    end

    % MATLAB builtin methods
    methods
        function S = struct(obj)
            S = struct();
            S.PrimitiveType = string(obj.PRIMITIVE_TYPE);
            S.Required = obj.Required;

            [validators, decorators] = aod.schema.util.getValidatorsAndDecorators(obj);
            for i = 1:numel(validators)
                if validators(i) == "Size" && obj.Size.isSpecified()
                    % TODO: Should be method
                    value = obj.(validators(i)).text();
                else
                    value = obj.(validators(i)).Value;
                end
                S.(validators(i)) = value;
            end
            for i = 1:numel(decorators)
                S.(decorators(i)) = obj.(decorators(i)).Value;
            end
        end

        function tf = isequal(obj, other)
            % Determine if two primitives are equal
            %
            % Syntax:
            %   tf = isequal(obj, other)
            % -------------------------------------------------------------
            if ~isa(other, 'aod.schema.Primitive')
                tf = false;
                return
            end

            if ~isequal(obj.PRIMITIVE_TYPE, other.PRIMITIVE_TYPE)
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