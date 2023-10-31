classdef FileCollection < aod.schema.SchemaCollection

    properties (Hidden, SetAccess = protected)
        schemaType = "File";
        ALLOWABLE_PRIMITIVE_TYPES = aod.schema.primitives.PrimitiveTypes.FILE
    end

    methods
        function obj = FileCollection(parent)
            obj = obj@aod.schema.SchemaCollection(parent);
        end
    end

    methods
        function add(obj, fileName, varargin)
            if isa(fileName, 'aod.schema.Record')
                entry = fileName;
                if ~aod.schema.util.isPrimitiveType(entry, 'file')
                    error('add:InvalidPrimitiveType',...
                        'FileCollection only accepts File primitives, not %s', entry.primitiveType);
                end
            else
                % File doesn't need to be specified as it's the only
                % primitive type that can be added to a FileCollection, but
                % don't penalize users for being thorough...
                if strcmpi(varargin{1}, 'file')
                    startIdx = 2;
                else % Make sure a non-file primitive type wasn't specified
                    try
                        primitiveType = aod.schema.primitives.PrimitiveTypes.get(varargin{1});
                        if primitiveType ~= aod.schema.primitives.PrimitiveTypes.FILE
                            error('add:InvalidPrimitiveType',...
                                'FileCollection only accepts File primitives, not %s', char(primitiveType));
                        end
                    catch ME
                        if strcmp(ME.identifier, 'add:InvalidPrimitiveType')
                            rethrow(ME);
                        end
                        startIdx = 1;
                        % No need to do anything, this line wasn't supposed to run
                    end
                end
                entry = aod.schema.Record(obj, fileName, 'file', varargin{startIdx:end});
            end

            add@aod.schema.SchemaCollection(obj, entry);
        end

        function ip = getParser(obj)
            % Amazingly this works
            ip = aod.util.InputParser();
            for i = 1:obj.Count
                addParameter(ip, obj.Records(i).Name,...
                    obj.Records(i).Primitive.Default, ...
                    @(x) obj.Records(i).Primitive.validate(x));
            end
        end
    end


    methods (Access = ?aod.schema.Schema)
        function setClassName(obj, className)
            % Set the class name
            %
            % Description:
            %   Used by core interface to support the use of a static method
            %   for determining inherited and specified attributes
            %
            % Syntax:
            %   setClassName(obj, className)
            % -------------------------------------------------------------
            obj.className = className;
        end
    end

    methods (Static)
        function obj = populate(className)
            % Create SchemaCollection independent of parent entity
            obj = aod.schema.util.StandaloneSchema(className);
            obj = obj.Attributes;
        end
    end
end
