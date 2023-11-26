classdef RecordCollectionNode < aod.schema.exceptions.tree.ExceptionNode

    properties (SetAccess = private)
        recordType              aod.schema.RecordTypes
    end

    methods
        function obj = RecordCollectionNode(collection, varargin)
            arguments
                collection      aod.schema.exceptions.RecordCollection
            end

            arguments (Repeating)
                varargin
            end

            obj = obj@aod.schema.exceptions.tree.ExceptionNode(varargin{:});

            obj.recordType = collection.recordType;
        end

        function addChildren(obj, children)
            arguments
                obj       (1,1)     aod.schema.exceptions.tree.RecordCollectionNode
                children            aod.schema.exceptions.tree.RecordNode
            end

            for i = 1:numel(children)
                assert(children(i).recordType == obj.recordType,...
                    'addChildren:InvalidRecordType',...
                    'Child must have the same record type as parent (%s)', string(obj.recordType));
            end

            addChildren@aod.schema.exceptions.tree.ExceptionNode(obj, children);
        end
    end
end