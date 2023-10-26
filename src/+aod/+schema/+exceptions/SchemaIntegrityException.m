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
    end

    properties (Dependent)
        hasErrors
    end

    methods
        function obj = SchemaIntegrityException(entry)
            if isSubclass(entry, 'aod.schema.primitives.Primitive')
                if isempty(entry.Parent)
                    % This is for testing, perhaps eliminate bc messy
                    obj.Exception = MException(...
                        'checkIntegrity:SchemaConflictsDetected',...
                        'Schema conflicts detected.');
                else
                    entry = entry.Parent;
                end
            end
            if isa(entry, 'aod.schema.Record')
                obj.Exception = MException('checkIntegrity:SchemaConflictsDetected',...
                    'Schema conflicts detected for "%s/%s" in %s',...
                    entry.className, string(entry.Name), entry.ParentPath);
            end
        end

        function value = get.hasErrors(obj)
            value = ~isempty(obj.Exception.cause);
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