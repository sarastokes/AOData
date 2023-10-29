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
        Parent                  % aod.schema.Record, aod.schema.primitives.Container
        Name        (1,1)       string
        isRequired  (1,1)       logical = false
        Default     (1,1)       aod.schema.Default
        Class       (1,1)       aod.schema.validators.Class
        Description (1,1)       aod.schema.decorators.Description
        Size                    aod.schema.validators.Size
    end

    properties (Hidden, SetAccess = protected)
        % Determines which aspects of an AOData entity the primitive can
        % be used to describe. Some may not be valid for attributes and
        % almost all are not valid for files.
        ALLOWABLE_PARENT_TYPES = ["Dataset", "Attribute", "File"];
        % Holds integrity checks until object is constructed
        isInitializing  (1,1)   logical = true
    end

    properties (Hidden, SetAccess = private)
        % Whether primitive is part of a Container subclass
        isNested        (1,1)   logical = false
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
            obj.Size = aod.schema.validators.Size([], obj);
            obj.Class = aod.schema.validators.Class([], obj);
            obj.Default = aod.schema.Default(obj, []);
            obj.Description = aod.schema.decorators.Description([], obj);
        end

        function record = getRecord(obj)
            if isempty(obj.Parent)
                record = [];
                return
            end

            parent = obj.Parent;
            while ~isa(parent, 'aod.schema.Record')
                parent = parent.Parent;
                if isempty(parent)
                    break
                end
            end
            record = parent;
        end

        function parentObj = getParent(obj, parentType)
            arguments
                obj
                parentType      {mustBeMember(parentType, ["", "Record", "Collection", "Entity"])} = ""
            end

            parentObj = obj.Parent;
            if isempty(parentObj) || parentType == ""
                return
            end

            switch parentType
                case "Record"
                    parentClass = "aod.schema.Record";
                case "Collection"
                    parentClass = "aod.schema.SchemaCollection";
                case "Entity"
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

    methods (Sealed)
        function setRequired(obj, value)
            arguments
                obj
                value   (1,1)    logical
            end

            obj.isRequired = value;
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
            obj.Size = aod.schema.validators.Size(value);
            obj.checkIntegrity(true);
        end

        function setClass(obj, value)
            obj.Class.setValue(value);
            obj.checkIntegrity(true);
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

        function [tf, ME] = validate(obj, value, errorType)
            arguments
                obj
                value
                errorType           = aod.infra.ErrorTypes.ERROR
            end

            errorType = aod.infra.ErrorTypes.init(errorType);

            tf = true; MEs = [];
            numFailures = 0;
            for i = 1:numel(obj.VALIDATORS)
                [itf, iME] = obj.(obj.VALIDATORS(i)).validate(value);
                if ~itf
                    tf = false;
                    numFailures = numFailures + 1;
                    MEs = cat(1, MEs, iME);
                end
            end

            if numFailures == 0
                ME = [];
                return
            end

            % TODO Put this in a function too sometimes primitive may
            % need to handle this?
            if ~isempty(obj.Parent)
                msg = sprintf('Failed validation for %s/%s in %s',...
                    obj.Parent.className, obj.Name, obj.Parent.ParentPath);
            else
                msg = sprintf('Failed validation for %s', obj.Name);
            end
            ME = MException('validate:Failed', msg);
            for i = 1:numel(MEs)
                ME = addCause(ME, MEs(i));
            end

            % TODO Maybe a single function that gets called for this
            switch errorType
                case aod.infra.ErrorTypes.ERROR
                    throw(ME);
                case aod.infra.ErrorTypes.WARNING
                    warning(ME.identifier, ME.message);
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

            % TODO: Add required
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
            ip.addParameter('Required', false, @islogical);
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

            if aod.util.isempty(parent)
                obj.Parent = [];
                return
            end

            mustBeSubclass(parent, ["aod.schema.Record", "aod.schema.primitives.Container"]);
            if isa(parent, 'aod.schema.primitives.Container')
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
            S.(obj.Name) = struct();
            S.(obj.Name).PrimitiveType = string(obj.PRIMITIVE_TYPE);
            S.(obj.Name).isRequired = obj.isRequired;
            
            [validators, decorators] = aod.schema.util.getValidatorsAndDecorators(obj);
            for i = 1:numel(validators)
                if validators(i) == "Size"  % TODO: Should be method
                    value = obj.(validators(i)).text();
                else
                    value = obj.(validators(i)).Value;
                end
                S.(obj.Name).(validators(i)) = value; %.jsonencode();
            end
            for i = 1:numel(decorators)
                S.(obj.Name).(decorators(i)) = obj.(decorators(i)).Value; %.jsonencode();
            end
        end

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