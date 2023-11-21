classdef RecordComparison < handle
% RECORDCOMPARISON

% By Sara Patterson, 2023 (AOData)
% ------------------------------------------------------------------------

    properties (SetAccess = private)
        A                   % aod.schema.Record
        B                   % aod.schema.Record
        ChangeLog           table
    end

    methods
        function obj = RecordComparison(A, B)
            arguments
                A           aod.schema.Record
                B           aod.schema.Record
            end

            obj.A = A;
            obj.B = B;

            obj.ChangeLog = array2table(double.empty(0,3),...
                'VariableNames', {'SchemaType', 'MatchType', 'Lineage'});
        end

        function doComparison(obj)
            obj.comparePrimitives(obj.A.Primitive, obj.B.Primitive)
            obj.comparePrimitiveSpecs(obj.A.Primitive, obj.B.Primitive)
            if obj.A.Primitive.isContainer && obj.B.Primitive.isContainer
                % TODO: Named item comparison, this is for indexed items
                if obj.A.Primitive.numItems > obj.B.Primitive.numItems
                    obj.logComparison(aod.schema.SchemaTypes.ITEM, aod.schema.MatchType.REMOVED);
                elseif obj.A.Primitive.numItems < obj.B.Primitive.numItems
                    obj.logComparison(aod.schema.SchemaTypes.ITEM, aod.schema.MatchType.ADDED);
                else
                    for i = 1:obj.A.Primitive.numItems
                        obj.comparePrimitives(obj.A.Primitive.getItem(i), obj.B.Primitive.getItem(i));
                        obj.comparePrimitiveSpecs(obj.A.Primitive.getItem(i), obj.B.Primitive.getItem(i));
                    end
                end
            end
        end

        function showTable(obj)
            logTable = obj.ChangeLog;
            logTable.SchemaType = string(logTable.SchemaType);
            logTable.MatchType = string(logTable.MatchType);
            tt = TextTable();
            tt.table_title = sprintf("Changes in %s", aod.schema.util.traceSchemaLineage(obj.A));
            tt.addColumns({"SchemaType", "MatchType", "Lineage"},...
                [-1, -1, -1], [3 3 3]);
            for i = 1:height(logTable)
                tt.addRows(table2cell(logTable(i,:)), obj.ChangeLog.MatchType(i).getColor(true));
            end
            tt.print();
        end

        function comparePrimitives(obj, A1, B2)
            arguments
                obj
                A1          aod.schema.Primitive
                B2          aod.schema.Primitive
            end

            import aod.schema.MatchType

            if A1.PRIMITIVE_TYPE ~= B2.PRIMITIVE_TYPE
                primitiveComp = MatchType.CHANGED;
            elseif A1.PRIMITIVE_TYPE == aod.schema.PrimitiveTypes.UNKNOWN
                primitiveComp = MatchType.ADDED;
            elseif B2.PRIMITIVE_TYPE == aod.schema.PrimitiveTypes.UNKNOWN
                primitiveComp = MatchType.REMOVED;
            else
                primitiveComp = MatchType.SAME;
            end
            obj.logComparison(A1.SCHEMA_TYPE, primitiveComp, aod.schema.util.traceSchemaLineage(A1));

            % if A1.Name ~= B2.Name
            %     nameComp = MatchType.CHANGED;
            % else
            %     nameComp = MatchType.SAME;
            % end
            % obj.logComparison(A1.SCHEMA_TYPE, nameComp,...
            %     aod.schema.util.traceSchemaLineage(A1) + " \ Name");
        end

        function comparePrimitiveSpecs(obj, A1, B2)
            arguments
                obj
                A1          aod.schema.Primitive
                B2          aod.schema.Primitive
            end

            optsA = setdiff(A1.getOptions(), ["Items", "Required"]);
            optsB = setdiff(B2.getOptions(), ["Items", "Required"]);

            % Options in B but not in A
            newOpts = setdiff(optsB, optsA);
            for i = 1:numel(newOpts)
                obj.logComparison(...
                    B2.(newOpts(i)).SCHEMA_TYPE,...
                    aod.schema.MatchType.ADDED,...
                    aod.schema.util.traceSchemaLineage(B2.(newOpts(i))))
            end

            % Options in A but not in B
            oldOpts = setdiff(optsA, optsB);
            for i = 1:numel(oldOpts)
                obj.logComparison(...
                    A1.(oldOpts(i)).SCHEMA_TYPE,...
                    aod.schema.MatchType.REMOVED,...
                    aod.schema.util.traceSchemaLineage(A1.(newOpts(i))));
            end

            sharedOpts = intersect(optsA, optsB);
            for i = 1:numel(sharedOpts)
                compType = compare(A1.(sharedOpts(i)), B2.(sharedOpts(i)));
                obj.logComparison(A1.(sharedOpts(i)).SCHEMA_TYPE, compType,...
                    aod.schema.util.traceSchemaLineage(A1.(sharedOpts(i))));
            end
        end

        function logComparison(obj, schemaType, compType, lineageStr)
            obj.ChangeLog = [obj.ChangeLog; {schemaType, compType, lineageStr}];
        end
    end
end