function out = readAttributeByType(hdfName, data)

    % Parse char with option to convert to entity
    if ischar(data)
        % Could it be a datetime?
        try
            out = datetime(data);
        catch ME
            if ~strcmp(ME.id, 'MATLAB:datetime:UnrecognizedDateStringSuggestLocale')
                rethrow(ME);
            end
        end

        % Was it an enumerated type?
        try
            out = eval(data);
        catch ME
            if ~ismember(ME.id, {'MATLAB:undefinedVarOrClass', 'MATLAB:subscripting:classHasNoPropertyOrMethod'})
                rethrow(ME);
            end
        end

        out = data;
        return
    end

    % Was it logical?
    if isa(data, 'int32')
        out = logical(data);
        return
    end

    % Not a special case, return as is
    out = data;
