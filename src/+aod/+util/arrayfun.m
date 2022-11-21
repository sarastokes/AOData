function out = arrayfun(func, A)
    % ARRAYFUN
    %
    % Description:
    %   Wrapper for MATLAB's builtin arrayfun that first tries with
    %   UniformOutput set to true and then reverts to UniformOutput=false
    %   if unsuccessful.
    %
    % Syntax:
    %   out = arrayfun(func, A)
    %
    % See also:
    %   arrayfun
    %
    % TODO: Get the error message ID
    % ---------------------------------------------------------------------

    try
        out = arrayfun(func, A);
    catch 
        out = arrayfun(func, A, 'UniformOutput', false);
    end