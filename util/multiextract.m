function [matches, idx] = multiextract(txt, pattern, varargin)
    % MULTIEXTRACT
    %
    % Description:
    %   Runs extract on multiple inputs. Options for returning numbers
    %
    % Syntax:
    %   [matches, idx] = multiextract(txt, pattern, varargin)
    %
    % Inputs:
    %   txt                     cellstr or string array
    %   pattern                 search pattern
    % Optional key/value inputs:
    %   Numeric                 logical (default = false)
    %       Extract numbers from matches
    %   Sort                    logical (default = false)
    %       If returning numeric matches, sort in increasing order
    %
    % Outputs:
    %   matches                 Match results
    %   idx                     Indices of matches in original input
    %
    % See also:
    %   EXTRACT
    %
    % History:
    %   21Jul2022 - SSP
    % ---------------------------------------------------------------------
    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Numeric', false, @islogical);
    addParameter(ip, 'Sort', false, @islogical);
    parse(ip, varargin{:});

    returnNumbers = ip.Results.Numeric;
    sortNumbers = ip.Results.Sort;

    if iscellstr(txt)
        txt = string(txt);
    end

    idx = [];
    matches = string.empty();
    
    for i = 1:numel(txt)
        match = extract(txt(i), pattern);
        if ~isempty(match)
            idx = cat(1, idx, i);
            matches = cat(1, matches, match);
        end
    end

    if returnNumbers
        textMatches = matches;
        matches = zeros(numel(matches), 1);
        for i = 1:numel(matches)
            iMatch = char(textMatches(i));
            iMatch = iMatch(~isletter(iMatch) & ~isspace(iMatch));
            matches(i) = str2double(iMatch);
        end
        if sortNumbers
            [matches, sortedIdx] = sort(matches);
            idx = idx(sortedIdx);
        end
    end

    fprintf('MULTIEXTRACT: Found %u matches in %u inputs\n',...
        numel(matches), numel(txt));

