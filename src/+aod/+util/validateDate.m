function out = validateDate(dateIn)
    % VALIDATEDATE
    %
    % Description:
    %   Determines whether input is datetime and if not, converts using
    %   yyyyMMdd format.
    %
    % Syntax:
    %   out = validateDate(dateIn)
    % ---------------------------------------------------------------------

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