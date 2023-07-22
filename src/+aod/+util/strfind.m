function idx = strfind(txt, pattern, matchNumber)

    idx = strfind(txt, pattern);
    if nargin > 2
        if numel(idx) < matchNumber
            idx = [];
        else
            idx = idx(matchNumber);
        end
    end