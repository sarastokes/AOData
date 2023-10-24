classdef Categorical < aod.schema.primitives.Primitive
% CATEGORICAL
%
% Description:
%   A variable with a limited set of values
%
% Superclasses:
%   aod.schema.primitives.Primitive
%
% Notes:
%   "Enum" determines the value of "Format"

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (SetAccess = private)
        Enum                aod.schema.types.Enum
    end

    properties (Hidden, SetAccess = protected)
        OPTIONS = ["Enum", "Size", "Default", "Description"]
        VALIDATORS = ["Format", "Enum", "Size"];
    end

    methods
        function obj = Categorical(name, varargin)
            obj = obj@aod.schema.primitives.Primitive(name);

            % Initialize
            obj.Enum = aod.schema.validators.Enum(obj, []);

            % Fixed values
            % TODO: necessary to restrict to categorical?
            obj.Format.setValue('categorical');

            obj.setName(name);
            obj.parseInputs(varargin{:});
        end

        function tf = isValid(obj)
            tf = isValid@aod.schema.primitives.Categorical(obj);
            if ~tf
                return
            end
            tf = isempty(obj.Enum);
        end
    end

    methods
        function setEnum(obj, valueSet)
            obj.Enum.setValue(valueSet);
            obj.setFormat(class(valueSet));
        end
    end

    methods (Access = protected)
        function checkIntegrity(obj)
            checkIntegrity@aod.schema.primitives.Primitive(obj);
            if ~isempty(obj.Enum) && ~isempty(obj.Default)
                if ~ismember(obj.Default, obj.Enum)
                    error('checkIntegrity:InvalidItem',...
                        'Default value %s was not in enumeration',...
                        value2string(obj.Default));
                end
            end
        end
    end
end