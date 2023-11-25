classdef Text < aod.schema.Primitive
% TEXT - Defines a string or string array input
%
% Superclasses:
%   aod.schema.Primitive
%
% Constructor:
%   obj = aod.schema.primitives.Text(parent)
%   obj = aod.schema.primitives.Text(parent, 'Length', value,...
%       'Length', value, 'Enum', value, 'Description', value)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Length          aod.schema.validators.Length
        Enum            aod.schema.validators.Enum
        Regexp          aod.schema.validators.Regexp
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.TEXT
        OPTIONS = ["Size", "Length", "Enum", "Regexp", "Default", "Description"]
        VALIDATORS = ["Size", "Class", "Length", "Enum", "Regexp"];
    end

    methods
        function obj = Text(parent, varargin)
            obj = obj@aod.schema.Primitive(parent);

            % Initialization
            obj.Length = aod.schema.validators.Length(obj, []);
            obj.Enum = aod.schema.validators.Enum(obj, []);
            obj.Regexp = aod.schema.validators.Regexp(obj, []);

            % Defaults
            obj.setClass("string");
            obj.setDefault("");

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
                obj.Length.setValue([]);
            else
                obj.Length.setValue(value);
            end
            obj.checkIntegrity(true);
        end

        function setRegexp(obj, value)
            arguments
                obj
                value       string = ""
            end

            obj.Regexp.setValue(value);
            obj.checkIntegrity(true);
        end
    end

    methods
        function [tf, ME, excObj] = checkIntegrity(obj, throwErrors)
            if nargin < 2
                throwErrors = false;
            end
            if obj.isInitializing
                tf = true; ME = [];
                return
            end
            [~, ~, excObj] = checkIntegrity@aod.schema.Primitive(obj);

            if obj.Default.isSpecified()
                if obj.Length.isSpecified()
                    if any(arrayfun(@(x) ~isequal(strlength(x), obj.Length.Value), obj.Default.Value))
                        excObj.addCause(MException(...
                            'checkIntegrity:InvalidDefaultLength',...
                            'Default value did not match Length (%u)', obj.Length.Value));
                    end
                end
                if obj.Enum.isSpecified()
                    if ~any(ismember(obj.Default.Value, obj.Enum.Value))
                        excObj.addCause(MException(...
                            'checkIntegrity:InvalidDefaultValue',...
                            'Default value was not in Enum: %s', strjoin(obj.Enum.Value, ', ')));
                    end
                end
                if obj.Regexp.isSpecified()
                    if ~obj.Regexp.validate(obj.Default.Value)
                        excObj.addCause(MException(...
                            'checkIntegrity:InvalidDefaultRegexp',...
                            'Default value did not pass regexp validation'));
                    end
                end
            end

            if obj.Enum.isSpecified()
                if obj.Length.isSpecified()
                    if any(arrayfun(@(x) ~isequal(strlength(x), obj.Length.Value), obj.Enum.Value))
                        excObj.addCause(MException(...
                            'checkIntegrity:InvalidEnumLength',...
                            'Enum values did not match Length (%u)', obj.Length.Value));
                    end
                end
                if obj.Regexp.isSpecified
                    if ~arrayfun(@(x) obj.Regexp.validate(x), obj.Enum.Value)
                        excObj.addCause(MException(...
                            'checkIntegrity:InvalidEnumRegexp',...
                            'Enumeration values did not pass regexp validation'));
                    end
                end
            end

            tf = ~excObj.hasErrors();
            ME = excObj.getException();
            if excObj.hasErrors() && throwErrors
                throw(ME);
            end
        end
    end
end