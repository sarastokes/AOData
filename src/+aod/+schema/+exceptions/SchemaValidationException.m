classdef SchemaValidationException < handle
%
% Workflow:
%   1. Collect exceptions in Causes
%   2. Pass object up the schema hierarchy
%   3. To compile and throw, pass caller to use in message
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        Causes                      % MException
        Triggers                    string
    end

    properties (Dependent)
        numErrors        (1,1)      logical
    end

    methods
        function obj = SchemaValidationException()
            % Do nothing
        end
    end

    % Dependent set/get methods
    methods
        function value = get.numErrors(obj)
            value = numel(obj.Causes);
        end
    end

    methods
        function tf = isValid(obj)
            tf = isempty(obj.Causes);
        end

        function addCause(obj, ME, schemaObj)
            if isa(ME, 'aod.schema.exceptions.SchemaValidationException')
                % Merge in causes and triggers from 2nd object
                obj.Causes = [obj.Causes; ME.Causes];
                obj.Triggers = [obj.Triggers; ME.Triggers];
            else
                obj.Causes = [obj.Causes; ME];
            obj.Triggers = [obj.Triggers; aod.schema.util.traceSchemaLineage(schemaObj)];
            end
        end

        function ME = getException(obj, schemaObj)
            if nargin < 2
                schemaObj = [];
            end
            if obj.isValid()
                ME = [];
                return
            end

            id = 'validate:SchemaViolationsDetected';
            msg = sprintf('%u schema violations', obj.numErrors);
            if ~isempty(schemaObj)
                msg = [msg, ' in ', class(schemaObj)];
                % Don't run the rest of the if statements
            % elseif isSubclass(schemaObj, 'aod.schema.primitives.Container')
            %
            % elseif isSubclass(schemaObj, 'aod.schema.Primitive')
            %     if ~isempty(schemaObj.Parent)
            %         msg = sprintf('Failed validation for %s/%s in %s',...
            %             schemaObj.Parent.className, schemaObj.Name,...
            %             schemaObj.Parent.ParentPath);
            %     else
            %         msg = sprintf('Failed validation for %s', schemaObj.Name);
            %     end
            % elseif isa(schemaObj, 'aod.schema.Record')

            % elseif isSubclass(schemaObj, 'aod.schema.RecordCollection')
            end

            ME = MException(id, msg);
            for i = 1:obj.numErrors
                ME = addCause(ME, obj.Causes(i));
            end
        end
    end
end