function tf = isInputEmpty(input)

    input = convertCharsToStrings(input);
    if aod.util.isempty(input) || isequal(input, "[]")
        tf = true;
    elseif isstring(input) && all(isequal(input, "[]"))
        tf = true;
    else
        tf = false;
    end
