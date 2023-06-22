function out = combineFunctionHandles(fcns)
% Combine function handles into a single handle
%
% Description:
%   Combine function handles and wrap validation functions without an 
%   output in a tf function to ensure all can be run by inputParser. 
%   The input to all anonymous functions will be set to "x"
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
%   inputParser, aod.common.KeyValueMap, aod.specification.AttributeManager

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if isa(fcns, 'function_handle')
        fcns = {fcns};
    end
    txt = cellfun(@(x) string(func2str(x)), fcns);
    for i = 1:numel(txt)
        % Handle anonymous functions that do not start with @(x)
         if ~startsWith(txt(i), "@(x)")
            if startsWith(txt(i), "@(")
                fprintf('Fixing %s...', txt(i)) 
                varName = extractBetween(txt(i), "@(", ")");
                if isempty(varName)
                    continue
                end
                fprintf("Variable was %s, not ""x""...", varName);
                % Find matches that are not strings/chars
                pat = letterBoundary + varName + ... 
                    wildcardPattern(1,1,"Except", characterListPattern("""'"));
                matches = extract(txt(i), pat);
                for j = 1:numel(matches)
                    txt(i) = strrep(txt(i), matches(j),... 
                        strrep(matches(j), varName, "x"));
                end
                fprintf("%s.\n", txt(i));   
            end 
            if contains(txt(i), 'mustBeA(')
                txt(i) = strrep(txt(i), "mustBeA(", "aod.util.isa(");
            end
         end
    end

    catTxt = "";
    for i = 1:numel(txt)
        iFcn = txt(i);
        if i > 1
            catTxt = catTxt + " & ";
        end
        fInfo = functions(fcns{i});
        if contains(fInfo.type, 'simple') || contains(iFcn, 'mustBe')
            if ~startsWith(iFcn, "@")
                iFcn = "@" + iFcn;
            end
            catTxt = catTxt + "err2tf(" + iFcn + ",x)";
        else
            iFcn = erase(iFcn, "@(x)");
            catTxt = catTxt + iFcn;
        end
    end

    if ~startsWith(catTxt, "@(x)")
        catTxt = "@(x)" + catTxt;
    end

    out = str2func(catTxt);