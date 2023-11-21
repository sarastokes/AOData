classdef Datetime < aod.schema.Primitive
% Specifies a date and time (day, month, year)
%
% Constructor:
%   obj = aod.schema.primitives.Datetime(name, parent, varargin)
%
% TODO: Validation isn't rejecting - figure out a different approach

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Format              aod.schema.validators.Format
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.DATETIME
        OPTIONS = ["Class", "Size", "Format", "Description"];
        VALIDATORS = ["Class", "Size", "Format"];
    end

    methods
        function obj = Datetime(name, parent, varargin)
            obj = obj@aod.schema.Primitive(name, parent);

            obj.Format = aod.schema.validators.Format(obj, []);
            obj.setSize("(1,1)");
            obj.setFormat("yyyy-MM-dd HH:mm:ss");
            obj.setClass("datetime");  %% TODO - string/datetime

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end


    methods
        function setFormat(obj, value)
            arguments
                obj
                value          string
            end

            if aod.util.isempty(value)
                obj.Format.setValue([]);
                return
            end

            try
                testVariable = datetime('now', 'Format', value); %#ok<NASGU>
            catch ME
                if strcmp(ME.identifier, 'MATLAB:datetime:UnsupportedSymbol')
                    newME = MException('setFormat:InvalidFormat',...
                    'Invalid format string %s for datetime', value);
                    newME = addCause(newME, ME);
                    throw(newME);
                else
                    rethrow(ME);
                end
            end

            obj.Format.setValue(value);
            obj.checkIntegrity(true);
        end
    end

    methods
        function [tf, ME, excObj] = checkIntegrity(obj, throwErrors)
            arguments
                obj
                throwErrors         logical     = false
            end

            if obj.isInitializing
                return
            end

            [~, ~, excObj] = checkIntegrity@aod.schema.Primitive(obj);

            if obj.Default.isSpecified && obj.Format.isSpecified && isa(obj.Default.Value, ["datetime", "duration"])
                if ~obj.Format.validate(obj.Default.Value)
                    excObj.addException(MException('checkIntegrity:InvalidDefaultFormat',...
                    'Default value format %s does not match specified Format %s', obj.Default.Format, obj.Format.Value));
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