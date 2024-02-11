classdef File < aod.schema.Primitive
% FILE
%
% Superclasses:
%   aod.schema.Primitive
%
% TODO: IsRelative?

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Extension           aod.schema.validators.Extension
        Regexp              aod.schema.validators.Regexp
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.FILE
        OPTIONS = ["Extension", "Size", "Default", "Description"];
        VALIDATORS = ["Class", "Size", "Extension"];
    end

    methods
        function obj = File(parent, varargin)
            obj = obj@aod.schema.Primitive(parent);

            % Initialize
            obj.Extension = aod.schema.validators.Extension(obj, []);
            obj.Regexp = aod.schema.validators.Regexp(obj, []);

            % Defaults
            obj.setClass("string");  % TODO: is char ok?
            obj.setSize('(:,1)');

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function setExtension(obj, value)
            arguments
                obj
                value       string = ""
            end

            obj.Extension.setValue(value);
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

        function setDefault(obj, value)
            % Enforce string before assigning to default
            arguments
                obj
                value       string = ""
            end

            setDefault@aod.schema.Primitive(obj, value);
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

            if obj.Extension.isSpecified() && obj.Default.isSpecified()
                if ~endsWith(obj.Default.Value, obj.Extension.Value)
                    excObj.addCause(MException(...
                        'checkIntegrity:InvalidDefaultExtension',...
                        'Default extension value must be one of the following: %s', obj.Extension.text()));
                end
            end
            % TODO: Regular expression checks

            tf = ~excObj.hasErrors();
            ME = excObj.getException();
            if excObj.hasErrors() && throwErrors
                throw(ME);
            end
        end
    end
end