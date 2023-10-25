classdef Date < aod.schema.primitives.Primitive
% Specifies a date (day, month, year)
%
% Constructor:
%   obj = aod.schema.primitives.Date(name, parent, varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.DATE
        OPTIONS = ["Size", "Description"];
        VALIDATORS = ["Format", "Size"];
    end

    methods
        function obj = Date(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            obj.setSize("(1,1)");
            obj.setFormat("datetime");  %% TODO - yymmdd

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods (Access = protected)
        function tf = checkIntegrity(~, ~)
            tf = true; ME = [];
        end
    end
end