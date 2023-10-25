classdef Boolean < aod.schema.primitives.Primitive
% BOOLEAN - Specify a logical value (true/false or 0/1)
%
% Superclasses:
%   aod.schema.primitives.Primitive
%
% Constructor:
%   obj = aod.schema.primitives.Primitive(name, parent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.BOOLEAN
        OPTIONS = ["Size", "Default", "Description"]
        VALIDATORS = ["Format", "Size"];
    end

    methods
        function obj = Boolean(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            % Set default values
            obj.setFormat("logical");

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
                value       {mustBeNumericOrLogical}
            end

            if isempty(value)
                obj.Default.setValue([]);
                return
            end

            if islogical(value)
                obj.Default.setValue(value);
                return
            end

            if isa(value, 'double')
                if any(~ismember(value, [0 1]))
                    error('setDefault:InvalidInput',...
                        'Boolean defaults must be either 0 or 1.');
                else
                    obj.Default.setValue(logical(value));
                end
            end
            obj.checkIntegrity(true);
        end
    end

    methods
        function [tf, ME] = checkIntegrity(obj, throwError)
            arguments
                obj
                throwError      (1,1)       logical = false
            end

            if obj.isInitializing
                tf = true; ME = [];
                return
            end

            [tf, ME, excObj] = checkIntegrity@aod.schema.primitives.Primitive(obj);
            if ~tf && throwError
                throw(ME);
            end
        end
    end
end