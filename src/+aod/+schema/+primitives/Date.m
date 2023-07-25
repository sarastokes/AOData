classdef Date < aod.schema.primitives.Primitive
% Specifies a date (day, month, year)
%
% Constructor:
%   obj = aod.schema.primitives.Date(name, parent, varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        OPTIONS = "Description";
    end

    methods
        function obj = Date(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);
            obj.OPTIONS = "Description";
            obj.setSize("(1,1)");
            obj.setFormat("datetime");

            obj.parseInputs(varargin{:});
        end
    end

    methods (Access = protected)
        function checkIntegrity(~)
        end
    end
end