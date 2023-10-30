classdef SchemaIntegrityException < handle
% SCHEMAINTEGRITYEXCEPTION
%
% Description:
%   Create once, add causes but only return an exception if causes exist
%
% Constructor:
%   obj = SchemaIntegrityException(primitive)
%
% See also:
%   MException, addCause, aod.schema.Primitive

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Exception
        Triggers  % TODO: Log what triggered the MException causes
    end

    properties (Dependent)
        hasErrors       (1,1)       logical
    end

    methods
        function obj = SchemaIntegrityException(schemaObj)
            record = schemaObj.getRecord();
            if isempty(record)
                % This is for testing, perhaps eliminate bc messy
                obj.Exception = MException(...
                    'checkIntegrity:SchemaConflictsDetected',...
                    'Schema conflicts detected.');
                return
            end
            obj.Exception = MException('checkIntegrity:SchemaConflictsDetected',...
                'Schema conflicts detected for "%s"',...
                string(record.Name));
        end
    end

    methods
        function value = get.hasErrors(obj)
            value = ~isempty(obj.Exception.cause);
        end
    end

    methods
        function tf = isValid(obj)
            tf = isempty(obj.Exception.cause);
        end

        function addCause(obj, exception)
            arguments
                obj
                exception
            end

            obj.Exception = addCause(obj.Exception, exception);
        end

        function value = getException(obj)
            if obj.hasErrors
                value = obj.Exception;
            else
                value = [];
            end
        end
    end
end