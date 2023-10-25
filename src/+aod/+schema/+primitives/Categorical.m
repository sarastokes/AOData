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
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.CATEGORICAL
        OPTIONS = ["Enum", "Size", "Default", "Units", "Description"]
        VALIDATORS = ["Format", "Enum", "Size"];
    end

    methods
        function obj = Categorical(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            % Initialize
            obj.Enum = aod.schema.validators.Enum(obj, []);

            % Fixed values
            % TODO: necessary to restrict to categorical?
            obj.Format.setValue('categorical');

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
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

            obj.setFormat(class(valueSet));  % runs checkIntegrity()
        end
    end

    methods (Access = protected)
        function [tf, ME] = checkIntegrity(obj, throwErrors)
            arguments
                obj
                throwErrors         logical     = false
            end

            if obj.isInitializing
                tf = true; ME = [];
                return
            end

            [~, ~, excObj] = checkIntegrity@aod.schema.primitives.Primitive(obj);
            if ~isempty(obj.Enum) && ~isempty(obj.Default)
                if ~ismember(obj.Default, obj.Enum)
                    excObj.addCause(MException('checkIntegrity:InvalidItem',...
                        'Default value %s was not in enumeration',...
                        value2string(obj.Default)));
                end
            end


            tf = ~excObj.hasErrors();
            ME = excObj.getException();
            if excObj.hasErrors() && throwErrors
                throw(ME);
            end
        end
    end
end