classdef Text < aod.schema.primitives.Primitive


% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Length          aod.schema.specs.Length
        NumItems
        Enum
    end

    properties (Hidden, SetAccess = protected)
        OPTIONS = ["NumItems", "Length", "Enum", "Description"]
    end

    methods
        function obj = Text(name, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, varargin{:});

            % Initialization
            obj.Length = aod.schema.specis.Length([], obj);

            % Defaults
            obj.setFormat("string");
        end
    end

    methods
        function setNumItems(obj, value)
            arguments
                obj
                value     {mustBeScalarOrEmpty, mustBeInteger, mustBePositive} = []
            end

            if isempty(numItems)
                obj.NumItems = [];
            else
                obj.NumItems = value;
            end
        end

        function setLength(obj, value)
            arguments
                obj
                value       {mustBeScalarOrEmpty, mustBeInteger, mustBePositive} = []
            end

            if isempty(value)
                obj.Length.Value = [];
            else
                obj.Length.setValue(value);
            end
        end
    end

end