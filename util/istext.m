function tf = istext(obj)
    % ISTEXT
    %
    % Description:
    %   Returns true if input is of type string or char
    %
    % Syntax:
    %   tf = istext(obj)
    %
    % History:
    %   19Jul2022 - SSP
    % ---------------------------------------------------------------------
    
    tf = ischar(obj) | isstring(obj);
