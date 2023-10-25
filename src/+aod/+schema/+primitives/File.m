classdef File < aod.schema.primitives.Primitive
% FILE
%
% Superclasses:
%   aod.schema.primitives.Primitive
%
% TODO: IsRelative?

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        ExtensionType           aod.schema.validators.ExtensionType
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.FILE
        OPTIONS = ["ExtensionType", "Description"];
        VALIDATORS = ["Format", "ExtensionType"];
    end

    methods
        function obj = File(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            % Initialize
            obj.ExtensionType = aod.schema.validators.ExtensionType(obj, []);

            % Defaults
            obj.setFormat("string");  % TODO: is char ok?
            obj.setSize('(1,:)');

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function setExtensionType(obj, value)
            arguments
                obj
                value       string = ""
            end

            obj.ExtensionType.setValue(value);
            obj.checkIntegrity(true);
        end

        function setDefault(obj, value)
            % Enforce string before assigning to default
            arguments
                obj
                value       string = ""
            end

            setDefault@aod.schema.primitives.Primitive(obj, value);
        end
    end

    methods
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

            if ~isempty(obj.ExtensionType) && ~isempty(obj.Default)
                if ~endsWith(obj.Default.Value, obj.ExtensionType.Value)
                    excObj.addCause(MException(...
                        'checkIntegrity:InvalidDefaultExtension',...
                        'Default extension value must be one of the following: %s', obj.ExtensionType.text()));
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