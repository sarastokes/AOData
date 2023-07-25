classdef Unknown < aod.schema.primitives.Primitive
% A placeholder for unspecified datasets/attributes
%
% Superclasses:
%   aod.schema.specs.Primitive
%
% Constructor:
%   obj = aod.schema.primitives.Unknown(name, parent, varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        OPTIONS = ["Size", "Default", "Description"];
    end

    methods
        function obj = Unknown(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            obj.parseInputs(varargin{:});
        end
    end
end