function out = validateDate(dateIn)
% Validate YMD date
%
% Description:
%   Determines whether input is datetime and if not, converts using
%   yyyyMMdd format.
%
% Syntax:
%   out = aod.util.validateDate(dateIn)
%
% Inputs:
%   dateIn          datetime or char in yyyyMMdd format
%
% Outputs:
%   out             datetime 

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if isempty(dateIn)
        out = dateIn;
        return
    end

    if isdatetime(dateIn)
        out = dateIn;
    else
        try
            out = datetime(dateIn, 'Format', 'yyyyMMdd');
        catch ME 
            if strcmp(ME.identifier, 'MATLAB:datestr:ConvertToDateNumber')
                error("setCalibrationDate:FailedDatetimeConversion",...
                    "Failed to convert to datetime, use format yyyyMMdd");
            else
                rethrow(ME);
            end
        end
    end