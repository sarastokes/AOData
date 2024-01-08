classdef Complex < aod.schema.Primitive
% BOOLEAN - Specify a complex number
%
% Superclasses:
%   aod.schema.Primitive
%
% Constructor:
%   obj = aod.schema.Complex(parent, varargin)

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.COMPLEX
        OPTIONS = ["Size", "Default", "Description"]
        VALIDATORS = ["Class", "Size"]
    end

    methods
        function obj = Complex(parent, varargin)
            obj = obj@aod.schema.Primitive(parent);

            % Set default values
            obj.setClass("double");

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
                value           double
            end

            if isempty(value)
                obj.Default.setValue([]);
                return
            end

            if isnumeric(value) && isreal(value)
                error('setDefault:InvalidInput',...
                    'Complex defaults cannot be real numbers.');
            end
            obj.Default.setValue(value);

            obj.checkIntegrity(true);
        end
    end

    methods
        function [tf, ME, excObj] = checkIntegrity(obj, throwError)
            arguments
                obj
                throwError      (1,1)       logical = false
            end

            if obj.isInitializing
                tf = true; ME = [];
                return
            end

            [tf, ME, excObj] = checkIntegrity@aod.schema.Primitive(obj);
            if ~tf && throwError
                throw(ME);
            end
        end
    end
end