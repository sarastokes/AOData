function [value, tf] = extractFlaggedNumber(txt, flagStr, leadingFlag)
% EXTRACTFLAGGEDNUMBER
%
% Description:
%   Extract numbers from text with a trailing flag (e.g. '80t', '3pix')
%
% Syntax:
%   [value, tf] = extractFlaggedNumber(txt, flagStr, leadingFlag)
%
% Input:
%   txt                     text to search
%       
%   leadingFlag             logical (default = false)
%       Whether the flag before the number
%
% History:
%   16Jul2022 - SSP
%   25Jul2022 - SSP - switched trailingFlag to leadingFlag
% -------------------------------------------------------------------------
    if nargin < 3
        leadingFlag = false;
    end

    if ~leadingFlag 
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
        if leadingFlag
            value = str2double(out(numel(flagStr)+1:end));
        else
            value = str2double(out(1:end-numel(flagStr)));
        end
    end