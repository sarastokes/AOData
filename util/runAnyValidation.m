function [tf, ME] = runAnyValidation(fcn, value, errFlag)
% Run true/false and error output validations agnostically
%
% Syntax:
%   [tf, ME] = runAnyValidation(fcn, value, errFlag)
%
% Inputs:
%   fcn                 function handle
%   value           
%       The value to validate
% Optional inputs:
%   errFlag             logical
%       Whether to throw an error or return true/false
%
% Outputs:
%   tf                  logical
%       Whether the value passed the validation
%   ME                  MException
%       Error information, if one was thrown

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        errFlag = false;
    end

    hasOutput = (nargout(fcn) > 0);

    if hasOutput
        try
            tf = fcn(value);
            if ~islogical(tf)
                error('runAnyValidation:InvalidOutput',...
                    'Output should be logical, instead it was %s', class(tf));
            end
        catch ME
            error('runAnyValidation:InvalidFunction',...
                'The validation function %s errored: %s',...
                func2str(fcn), ME.message);
        end

        if tf 
            ME = [];
        else
            ME = MException('runAnyValidation:Failed',...
                'Input did not pass %s', func2str(fcn));
            if errFlag 
                throw(ME);
            end
        end
    else
        try 
            fcn(value);
            ME = [];
            tf = true;
        catch ME 
            tf = false;
            if errFlag 
                rethrow(ME);
            end
        end
    end