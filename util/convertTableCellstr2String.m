function T = convertTableCellstr2String(T)
% CONVERTTABLECELLSTR2STRING
%
% Description:
%   Convert any cellstr column to string in a table
%
% Syntax:
%   T = convertTableCellstr2String(T)
%
% Inputs:
%   T       table

% By Sara Patterson, 2023 (AOData)
% -----------------------------------------------------------------------

    arguments
        T       table
    end

    vNames = string(T.Properties.VariableNames);

    for i = 1:length(vNames)
        if iscellstr(T.(vNames(i)))  %#ok<ISCLSTR>
            T.(vNames(i)) = string(T.(vNames(i)));
        end
    end
