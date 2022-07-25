function value = extractCrop(txt, varargin)
    % EXTRACTCROP
    %
    % Description:
    %   Runs extract and returns only the text corresponding to
    %   digitsPattern or lettersPattern
    %
    % Syntax:
    %   value = extractCrop(txt, varargin)
    %
    % Example:
    %   extractCrop("rgw_seq_5p_200t", lettersPattern(), "_seq")
    %       >>> "rgw"
    %   extractCrop("rgw_seq_5p", "seq_", digitsPattern(), "p")
    %       >>> "5"
    %
    % History:
    %   25Jul2022 - SSP
    % ---------------------------------------------------------------------

    isPattern = false(1, numel(varargin{:}));
    pattern = "";
    for i = 1:numel(varargin)
        if isa(varargin{i}, 'pattern')
            isPattern(i) = true;
        end
        pattern = pattern + varargin{i};
    end

    match = extract(txt, pattern);

    if numel(isPattern) == 3
        value = extractBetween(match, varargin{1}, varargin{3});
    elseif isPattern(1)
        value = extractBefore(match, varargin{2});
    elseif isPattern(2) 
        value = extractAfter(match, varargin{1});
    end

    if iscell(value) && numel(value) == 1
        value = value{:};
    end
       


    