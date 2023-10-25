classdef FileCollection < aod.schema.SchemaCollection

    properties (Hidden, SetAccess = protected)
        schemaType = "File";
    end

    methods
        function obj = FileCollection(className, parent)
            arguments
                className       string    = []
                parent                    = []
            end
            obj = obj@aod.schema.SchemaCollection(className, parent);
        end
    end

    methods
        function add(obj, fileName, varargin)
            if isa(fileName, 'aod.schema.Entry')
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
                entry = aod.schema.Entry(obj, fileName, 'file', varargin{startIdx:end});
            end

            add@aod.schema.SchemaCollection(obj, entry);
        end
    end
end
