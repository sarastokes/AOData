function [tf, output] = isfunctionhandle(input)
% Tests whether input is function handle and optionally standardizes
%
% Syntax:
%   [tf, output] = isfunctionhandle(input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    output = [];
    tf = false;

    if isa(input, 'function_handle')
        % Scalar function handle
        tf = true;  
        output = {input};
    elseif istext(input)
        % Text convertable to function handle
        if iscellstr(input)
            input = string(input);
        end
        try
            output = arrayfun(@str2func, input, 'UniformOutput', false);
            tf = true;
        catch  
            tf = false;
        end
    elseif iscell(input)
        % Cell containing one or more function handles
        tf = all(cellfun(@(x) isa(x, 'function_handle'), input));
        output = input;
    end