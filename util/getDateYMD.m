function out = getDateYMD(txt)
% GETDATEYMD
%
% Description:
%   Convert text in yyyyMMdd format to datetime
%
% Syntax:
%   out = getDateYMD()
%   out = getDateYMD(txt)
%
% Input:
%   txt             char or string, date in 'yyyyMMdd' format
%
% Output:
%   datetime
%
% Notes:
%   If no input argument is provided, today's date will be returned
%
% History:
%   21Oct2022 - SSP
% -------------------------------------------------------------------------

    if nargin < 1
        out = datetime('now', 'Format', 'yyyyMMdd');
        return
    end

    if isdatetime(txt)
        out = txt;
        return
    end

    if isstring(txt)
        txt = char(txt);
    end

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