function out = getDateYMD(txt)
% GETDATEYMD
%
% Description:
%   Convert text in yyyyMMdd format to datetime
%
% Syntax:
%   out = getDateYMD(txt)
%
% Input:
%   txt             char or string, date in 'yyyyMMdd' format
%
% Output:
%   datetime
%
% History:
%   21Oct2022 - SSP
% -------------------------------------------------------------------------

    if isdatetime(txt)
        out = txt;
        return
    end

    if isstring(txt)
        txt = char(txt);
    end

    if nargin < 1
        out = datetime('now', 'Format', 'yyyyMMdd');
    else
        try
            out = datetime(txt, 'Format', 'yyyyMMdd');
        catch ME
            if strcmp(ME.identifier, 'MATLAB:datestr:ConvertToDateNumber')
                error("getDateYMD:FailedDatetimeConversion", ...
                "Failed to convert to datetime, use format yyyyMMdd");
            else
                rethrow(ME);
            end
        end
    end