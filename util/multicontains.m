function idx = multicontains(str, pats)

    fun = @(s) ~cellfun('isempty', strfind(str, s));
    out = cellfun(fun, pats', 'UniformOutput', false);
    idx = all(horzcat(out{:}), 2);