classdef Entry < handle
% This is where primitive type changes would be handled

    properties
        Parent                  % aod.schema.SpecificationManager
        Primitive               % aod.schema.primitives.Primitive
        definingClassName   (1,1)   string  = "UndefinedClass"
    end

    properties (Dependent)
        Name                (1,1)   string
        primitiveType           % aod.schema.primitives.PrimitiveTypes
        ParentPath          (1,1)   string
    end

    methods
        function obj = Entry(parent, name, type, varargin)
            if ~isempty(parent)
                obj.setParent(parent);  % empty parent support for testing
            end

            obj.Primitive = aod.schema.util.createPrimitive(...
                type, name, varargin{:});
        end

        function value = get.Name(obj)
            value = obj.Primitive.Name;
        end

        function value = get.primitiveType(obj)
            value = obj.Primitive.PRIMITIVE_TYPE;
        end

        function value = get.ParentPath(obj)
            if ~isempty(obj.Parent)
                value = obj.Parent.Path;
            else
                value = "";
            end
        end
    end

    methods
        function [tf, ME] = validate(obj, value)
            % Exception should contain:
            %   - Class and entry name
            %   - Number of failures
            %   - Names of failed validators
            % TODO: Keep summary???

            % if nargin < 3
            %     verbose = true; % suppress when running lots of Entry objs
            % end

            tf = true; MEs = []; % summary = "";
            numFailures = 0;
            for i = 1:numel(obj.Primitive.VALIDATORS)
                [itf, iME] = obj.Primitive.(obj.Primitive.VALIDATORS(i)).validate(value);
                if ~itf
                    tf = false;
                    numFailures = numFailures + 1;
                    MEs = cat(1, MEs, iME);
                    % summary = summary + sprintf("\t%s - %s: %s\n",...
                    %     obj.Primitive.VALIDATORS(i), iME.identifier, iME.message);
                end
            end

            if numFailures == 0
                ME = [];
                % summary = summary + sprintf("%s - %s: passed",...
                %     obj.definingClassName, obj.Name);
                return
            end
            % summary = summary + sprintf("%s - %s: %u failures (%s)\n",...
            %     obj.definingClassName, obj.Name, numFailures,...
            %     strjoin(obj.Primitive.VALIDATORS(~itf), ", "));

            ME = MException('validate:Failed',...
                'Failed validation for "%s/%s" in %s',...
                    obj.definingClassName, obj.Name, obj.ParentPath);
            for i = 1:numel(MEs)
                ME = addCause(ME, MEs(i));
            end

            % if verbose
            %     fprintf(summary + "\n");
            % end
        end
    end

    methods (Access = private)
        function setParent(obj, parent)
            arguments
                obj
                parent      {mustBeSubclass(parent, 'aod.schema.SchemaCollection')}
            end

            obj.Parent = parent;
            if ~isempty(parent.Parent)
                obj.definingClassName = class(parent.Parent);
            end
        end
    end

    % MATLAB builtin functions
    methods
        function tf = isequal(obj, other)
            if ~isSubclass(other, 'aod.schema.Entry')
                tf = false;
            else
                tf = isequal(obj.Primitive, other.Primitive);
            end
        end
    end
end