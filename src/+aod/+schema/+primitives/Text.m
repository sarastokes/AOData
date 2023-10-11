classdef Text < aod.schema.primitives.Primitive
% TEXT - Defines a string or string array input
%
% Superclasses:
%   aod.schema.primitives.Primitive
%
% Constructor:
%   obj = aod.schema.primitives.Text(name)
%   obj = aod.schema.primitives.Text(name, 'Length', value,...
%       'Count', value, 'Enum', value, 'Description', value)
%
% Allowed parents:
%   aod.specification.Entry, aod.schema.primitives.Table

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Length          aod.schema.specs.Length
        Count           aod.schema.specs.Count
        Enum            aod.schema.specs.Enum
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.TEXT
        OPTIONS = ["NumItems", "Length", "Enum", "Description"]
    end

    methods
        function obj = Text(name, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, varargin{:});

            % Initialization
            obj.Length = aod.schema.specs.Length([], obj);
            obj.Enum = aod.schema.specs.Enum([], obj);
            obj.Count = aod.schema.specs.Count([], obj);

            % Defaults
            obj.setFormat("string");
        end
    end

    methods
        function setCount(obj, value)
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

        function setEnum(obj, value)
            arguments
                obj
                value  (1,:)  string = ""
            end

            obj.Enum.setValue(value);
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