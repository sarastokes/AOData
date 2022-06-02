function value = getTodaysDate()
    % GETTODAYSDATE
    %
    % Description:
    %   Convenience method to get today's date formatted like 02Jun2022
    %
    % Syntax:
    %   value = getTodaysDate()
    %
    % History:
    %   02Jun2022 - SSP
    % ---------------------------------------------------------------------
    value = datetime(datestr(now), 'Format', 'ddMMMuuuu');