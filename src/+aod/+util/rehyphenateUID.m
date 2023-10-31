function out = rehyphenateUID(uidIn)

    arguments
        uidIn           string
    end

    if ~isscalar(uidIn)
        out = arrayfun(@(x) aod.util.rehyphenateUID(x), uidIn);
        return
    end

    uidIn = convertStringsToChars(uidIn);
    out = [uidIn(1:8) '-' uidIn(9:12) '-' uidIn(13:16) '-' uidIn(17:20) '-' uidIn(21:32)];
    out = string(out);