function txt = camelCase(txt, flag)
    if nargin < 2
        flag = true;
    end
    
    assert(istext(txt), 'Input must be char or string')
    isString = isstring(txt);
    if isString
        txt = char(txt);
    end

    if flag
        txt(1) = lower(txt(1));
    else
        txt(1) = upper(txt(1));
    end

    if isString
        txt = string(txt);
    end