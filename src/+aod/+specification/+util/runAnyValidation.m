function [tf, exception] = runAnyValidation(fcn, value, errFlag)
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

    if nargin < 3
        errFlag = false;
    end

    hasOutput = (nargout(fcn) ~= 0);

    if hasOutput
        try
            tf = fcn(value);
            if ~islogical(tf)
                error('validate:InvalidOutput',...
                    'Function %s returned type %s, but should return logical',...
                    func2str(fcn), class(tf));
            end
        catch ME
            error('runAnyValidation:InvalidFunction',...
                'The validation function %s errored: %s',...
                func2str(fcn), ME.message);
        end

        if tf 
            exception = [];
        else
            exception = MException('runAnyValidation:ReturnedFalse',...
                'Input did not pass "%s"', func2str(fcn));
            if errFlag 
                throw(exception);
            end
        end
    else
        try 
            fcn(value);
            exception = [];
            tf = true;
        catch ME 
            tf = false;
            exception = ME;
            if errFlag 
                rethrow(ME);
            end
        end
    end