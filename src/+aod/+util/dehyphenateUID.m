function out = dehyphenateUID(uidIn)
    arguments
        uidIn           string
    end

    if ~isscalar(uidIn)
        out = arrayfun(@(x) aod.util.dehyphenateUID(x), uidIn);
        return
    end

    if strlength(uidIn) ~= 36
        error('dehyphenateUID:InvalidInput',...
            'UIDs with hyphens contain 36 characters, not %u', strlength(uidIn));
    end
    out = erase(uidIn, "-");
