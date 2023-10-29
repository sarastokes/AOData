function out = getDateYMD(txt, format)
% GETDATEYMD
%
% Description:
%   Convert text in to datetime in a specific format
%
% Syntax:
%   out = getDateYMD()
%   out = getDateYMD(txt)
%   out = getDateYMD(txt, format)
%
% Input:
%   txt             char or string of date
%       Date to convert, if empty then "now" will be used
%   format          char or string
%       Format for datetime (default is 'yyyy-MM-dd')
%
% Output:
%   datetime
%
% Notes:
%   If no input argument is provided, today's date will be returned
%
% History:
%   21Oct2022 - SSP
%   28Oct2023 - SSP - Added option to specify format, switched to ISO
% -------------------------------------------------------------------------

    if nargin < 2
        format = 'yyyy-MM-dd';
    end

    if nargin < 1 || isempty(txt)
        out = datetime('now', 'Format', format);
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
        out = datetime(txt, 'Format', format);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:datestr:ConvertToDateNumber')
            error("getDateYMD:FailedDatetimeConversion", ...
            "Failed to convert to datetime, use format %s", format);
        else
            rethrow(ME);
        end
    end