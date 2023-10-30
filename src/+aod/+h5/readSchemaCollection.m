function collection = readSchemaCollection(S, collection, isNested)
    if nargin < 3
        isNested = false;
    end

    if isempty(S)
        return
    end

    recordNames = string(fieldnames(S));

    for i = 1:numel(recordNames)
        primitive = S.(recordNames(i));
        specs = string(fieldnames(primitive));
        if isNested
            record = aod.schema.util.createPrimitive(primitive.PrimitiveType,...
                recordNames(i), collection);
            userOpts = record.OPTIONS;
        else
            record = aod.schema.Record(collection, recordNames(i), primitive.PrimitiveType);
            userOpts = record.Primitive.OPTIONS;
        end
        idx = structfun(@(x) ~isempty(x), primitive) & ismember(specs, userOpts);
        idx(1) = false; % Remove "PrimitiveType" which is always first
        if nnz(idx) > 0
            % Extract the fields that aren't empty
            specOptions = rmfield(primitive, specs(~idx));
            record.assign(specOptions);
        end
        if isNested
            collection.Collection.add(record);
        else
            collection.add(record);
        end
    end
end