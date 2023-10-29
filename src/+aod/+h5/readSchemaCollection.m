function collection = readSchemaCollection(S, collection)
    if isempty(S)
        return
    end

    recordNames = string(fieldnames(S));

    for i = 1:numel(recordNames)
        primitive = S.(recordNames(i));
        specs = string(fieldnames(primitive));
        record = aod.schema.Record(collection, recordNames(i), primitive.PrimitiveType);
        idx = structfun(@(x) ~isempty(x), primitive) & ismember(specs, record.Primitive.OPTIONS);
        idx(1) = false; % Remove "PrimitiveType" which is always first
        if nnz(idx) > 0
            % Extract the fields that aren't empty
            specOptions = rmfield(primitive, specs(~idx));
            record.assign(specOptions);
        end
        collection.add(record);
    end
end