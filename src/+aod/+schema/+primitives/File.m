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
        ExtensionType
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveType.FILE
        OPTIONS = ["ExtensionType", "Description"];
        VALIDATORS = ["Format", "ExtensionType"];
    end

    methods
        function obj = File(name, varargin)
            obj = obj@aod.schema.primitives.Primitive(name);

            % Initialize
            obj.ExtensionType = aod.schema.primitives.ExtensionType(obj, []);

            % Defaults
            obj.setFormat("string");  % TODO: is char ok?
            obj.setSize('(1,:)');

            obj.setName(name);
            obj.parseInputs(varargin{:});
        end
    end

    methods
        function setExtensionType(obj, value)
            arguments
                obj
                value       string = ""
            end

            obj.ExtensionType.setValue(value);
        end
    end
end