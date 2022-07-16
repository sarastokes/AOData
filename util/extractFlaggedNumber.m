function [value, tf] = extractFlaggedNumber(txt, flagStr, trailingFlag)
% EXTRACTFLAGGEDNUMBER
%
% Description:
%   Extract numbers from text with a trailing flag (e.g. '80t', '3pix')
%
% Syntax:
%   [value, tf] = extractFlaggedNumber(txt, flagStr, trailingFlag)
%
% Input:
%   txt                     text to search
%       
%   trailingFlag            logical (default = true)
%       Whether the flag is after the number or not
%
% History:
%   16Jul2022 - SSP
% -------------------------------------------------------------------------
    if nargin < 3
        trailingFlag = true;
    end

    if trailingFlag 
        searchPattern = digitsPattern + flagStr;
    else
        searchPattern = flagStr + digitsPattern;
    end

    out = extract(txt, searchPattern);
    if isempty(out)
        value = [];
        tf = false;
    else
        tf = true;
        out = char(out);
        value = str2double(out(1:end-numel(flagStr)));
    end