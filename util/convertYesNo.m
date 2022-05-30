function tf = convertYesNo(txt)
    % CONVERTYESNO
    %
    % Description:
    %   Convert 'yes' or 'no' to true/false
    %
    % Syntax:
    %   tf = convertYesNo(txt)
    %
    % History:
    %   30May2022 - SSP
    % ---------------------------------------------------------------------
    
    switch lower(txt)
        case 'yes'
            tf = true;
        case 'no'
            tf = false;
        otherwise
            error('convertYesNo: Unrecognized input: %s', txt);
    end