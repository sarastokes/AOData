function x = enumStr(enum)
    % ENUMSTR  
    %
    % Description:
    %   Returns only the 2nd output of Matlab's enumeration fcn
    %
    % Syntax:
    %   x = enumStr(enum)
    %
    % Input:
    %   enum        Name of enumeration class as a char
    %
    % Output:
    %   x           Enumeration member names [Nx1 string array]
    % 
    % History:
    %   29Oct2017 - SSP
    %   31Jan2020 - SSP - Moved from ephys package, added documentation
    %   04Nov2020 - SSP - Changed output from cell of chars to string array
    % ---------------------------------------------------------------------

    [~, x] = enumeration(enum);
    x = string(x);