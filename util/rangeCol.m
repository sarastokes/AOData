function y = rangeCol(a, b)
    % RANGECOL
    %
    % Description:
    %   Just creates an array with : but returns a column instead of a row
    %
    % Syntax:
    %   y = rangeCol(a,b)
    %
    % History:
    %   06Mar2022 - SSP
    % ---------------------------------------------------------------------
    if nargin == 1 && numel(a) == 2
        b = a(2); a = a(1);
    end
    y = a:b;
    y = y';