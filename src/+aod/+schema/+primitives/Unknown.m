classdef Unknown < aod.schema.Primitive
% A placeholder for unspecified datasets/attributes
%
% Superclasses:
%   aod.schema.validators.Primitive
%
% Constructor:
%   obj = aod.schema.primitives.Unknown(parent, varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.UNKNOWN
        OPTIONS = ["Size", "Default", "Description"];
        VALIDATORS = "Size";
    end

    methods
        function obj = Unknown(parent, varargin)
            obj = obj@aod.schema.Primitive(parent);

            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
        end
    end
end