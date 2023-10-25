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
        Length          aod.schema.validators.Length
        Count           aod.schema.validators.Count
        Enum            aod.schema.validators.Enum
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.TEXT
        OPTIONS = ["NumItems", "Length", "Enum", "Description"]
        VALIDATORS = ["Format", "NumItems", "Length", "Enum"];
    end

    methods
        function obj = Text(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            % Initialization
            obj.Length = aod.schema.validators.Length([], obj);
            obj.Enum = aod.schema.validators.Enum([], obj);
            obj.Count = aod.schema.validators.Count([], obj);

            % Defaults
            obj.setFormat("string");

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function setDefault(obj, value)
            arguments
                obj
                value       string = ""
            end

            obj.Default.setValue(value);
            obj.checkIntegrity(true);
        end

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
            obj.checkIntegrity(true);
        end

        function setEnum(obj, value)
            arguments
                obj
                value  (1,:)  string = ""
            end

            obj.Enum.setValue(value);
            obj.checkIntegrity(true);
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
            obj.checkIntegrity(true);
        end
    end

    methods
        function [tf, ME] = checkIntegrity(obj, throwErrors)
            if nargin < 2
                throwErrors = false;
            end
            if obj.isInitializing
                tf = true; ME = [];
                return
            end
            [~, ~, excObj] = checkIntegrity@aod.schema.Primitive(obj);

            if ~aod.util.isempty(obj.Default)
                if ~isempty(obj.Length)
                    if all(strlength(obj.Default.Value) == obj.Length.Value)
                        excObj.addCause(MException(...
                            'checkIntegrity:InvalidDefaultLength',...
                            'Default value did not match Length (%u)', obj.Length.Value));
                    end
                elseif ~isempty(obj.Enum)
                    if ~any(ismember(obj.Default.Value, obj.Enum.Value))
                        excObj.addCause(MException(...
                            'checkIntegrity:InvalidDefaultValue',...
                            'Default value was not in Enum: %s', strjoin(obj.Enum.Value, ', ')));
                    end
                elseif ~isempty(obj.Count)
                    if numel(obj.Default.Value) ~= obj.Count.Value
                        excObj.addCause(MException(...
                            'checkIntegrity:InvalidDefaultCount',...
                            'Default value did not match Count (%u)', obj.Count.Value));
                    end
                end
            end

            if ~isempty(obj.Enum)
                if any(strlength(obj.Enum.Value) ~= obj.Length.Value)
                    excObj.addCause(MException(...
                        'checkIntegrity:InvalidEnumLength',...
                        'Enum values did not match Length (%u)', obj.Length.Value));
                end
            end

            ME = excObj.getException();
            tf = isempty(ME);
            if ~tf && throwErrors
                throw(ME);
            end
        end
    end
end