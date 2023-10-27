classdef SchemaValidationException < handle 
%
% Workflow:
%   1. Collect exceptions in Causes
%   2. Pass object up the schema hierarchy
%   3. To compile and throw, pass caller to use in message
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        Exception
        Causes
        Triggers
    end

    properties (Dependent)
        numErrors
    end

    methods
        function obj = SchemaValidationException()
            % Do nothing
        end

        function value = get.numErrors(obj)
            value = numel(obj.Causes);
        end

        function tf = isValid(obj)
            tf = ~isempty(obj.Causes);
        end

        function addCause(obj, ME, schemaObj)
            obj.Causes = [obj.Causes; ME];
            % TODO: Figure out how to log the object's path
            obj.Triggers = [obj.Triggers; schemaObj.Name];
        end

        function addLevel(obj, schemaObj)
            
        end

        function ME = getException(obj, schemaObj)
            if obj.isValid()
                ME = [];
                return
            end

            id = 'validate:SchemaViolationsDetected';
            msg = sprintf('%u schema violations', obj.numErrors);
            if isSubclass(schemaObj, 'aod.schema.primitives.Container')

            elseif isSubclass(schemaObj, 'aod.schema.primitives.Primitive')

            elseif isa(schemaObj, 'aod.schema.Record')

            elseif isSubclass(schemaObj, 'aod.schema.SchemaCollection')

            end

            ME = MException(id, msg);
            for i = 1:obj.numErrors
                ME = addCause(ME, obj.Causes(i));
            end
        end
    end
end