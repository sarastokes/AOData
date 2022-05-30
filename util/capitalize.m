function str = capitalize(str)
    % CAPITALIZE
    %
    % Description:
    %   Capitalize the first letter of text
    %
    % Syntax:
    %   str = capitalize(str)
    %
    % History:
    %   29May2022 - SSP
    % ---------------------------------------------------------------------

    str = [upper(str(1)), str(2:end)];