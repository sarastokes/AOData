function out = readAttributeByType(hdfName, pathName, attName)

    arguments
        hdfName     {mustBeFile(hdfName)}
        pathName    char
        attName     char
    end

    data = h5readatt(hdfName, pathName, attName);

    % Parse char with option to convert to entity
    if ischar(data)
        % Could it be a datetime?
        try
            out = datetime(data);
            return
        catch ME
            if ~strcmp(ME.identifier, 'MATLAB:datetime:UnrecognizedDateStringSuggestLocale')
                rethrow(ME);
            end
        end

        % Was it an enumerated type?
        try
            out = eval(data);
            return
        catch ME
            if ~ismember(ME.identifier, {'MATLAB:undefinedVarOrClass', 'MATLAB:subscripting:classHasNoPropertyOrMethod'})
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
