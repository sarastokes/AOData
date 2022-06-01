function idx = window2idx(window, singleRow)
    % WINDOW2IDX
    %
    % Description:
    %   Takes two integers and returns array of all integers between them
    % 
    % Syntax:
    %   idx = window2idx(window, singleRow)
    %
    % Inputs:
    %   window      array [N x 2]
    %       Start and stop points for array, each window is a row
    %   singleRow   logical (default = false)
    %       Single row output if multiple 
    %
    % Outputs:
    %   idx         array 
    %       Indices of all numbers contained within the N window(s)
    %
    % History:
    %   21Dec2021 - SSP
    %   10Mar2022 - SSP - Added single row output option
    % ---------------------------------------------------------------------

    if nargin < 2
        singleRow = false;
    end

    if numel(window) == 2
        idx = window(1):window(2);
    else
        idx = [];
        for i = 1:2:numel(window)
            idx = cat(1, idx, window(i):window(i+1));
        end
        if singleRow
            idx = idx(:)';
        end
    end
