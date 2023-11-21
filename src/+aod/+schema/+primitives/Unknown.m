classdef Unknown < aod.schema.Primitive
% A placeholder for unspecified datasets/attributes
%
% Superclasses:
%   aod.schema.validators.Primitive
%
% Constructor:
%   obj = aod.schema.primitives.Unknown(name, parent, varargin)
%
% TODO: Should UKNOWN be allowed to set any parameters

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.UNKNOWN
        OPTIONS = ["Size", "Default", "Description"];
        VALIDATORS = "Size";
    end

    methods
        function obj = Unknown(name, parent, varargin)
            obj = obj@aod.schema.Primitive(name, parent);

            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
        end
    end
end