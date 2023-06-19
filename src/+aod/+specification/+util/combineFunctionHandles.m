function out = combineFunctionHandles(fcns)
% Combine function handles 
%
% Description:
%   Combine function handles and wrap validation functions without an 
%   output in a tf function to ensure all can be run by inputParser
%
% Syntax:
%   out = aod.specification.util.combineFunctionHandles(fcns)
% 
% Inputs:
%   fcns            cell
%       A cell array of function handles
%
% Outputs:
%   out             function_handle
%       A single function handle combining all input handles
%
% See also:
%   inputParser, aod.specification.util.combineFunctionHandles

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    txt = cellfun(@(x) string(func2str(x)), fcns);

    catTxt = "";
    for i = 1:numel(txt)
        iFcn = txt(i);
        if i > 1
            catTxt = catTxt + " & ";
        end
        if nargout(fcns{i}) == 0
            iFcn = erase(iFcn, "@(x)");
            catTxt = catTxt + iFcn;
        else
            catTxt = catTxt + "aod.specification.util.runAnyValidation(" + iFcn + ",x)";
        end
    end

    out = str2func(catTxt);