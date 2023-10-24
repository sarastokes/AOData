classdef Date < aod.schema.primitives.Primitive
% Specifies a date (day, month, year)
%
% Constructor:
%   obj = aod.schema.primitives.Date(name, parent, varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.DATE
        OPTIONS = "Description";
        VALIDATORS = ["Format", "Size"];
    end

    methods
        function obj = Date(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);
            obj.setSize("(1,1)");
            obj.setFormat("datetime");  %% TODO - yymmdd

            obj.parseInputs(varargin{:});
        end
    end

    methods (Access = protected)
        function checkIntegrity(~)
        end
    end
end