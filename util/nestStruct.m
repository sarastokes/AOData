function S = nestStruct(S, fieldNames)
% NESTSTRUCT
%
% Description:
%   Convenience function for creating a nested struct
%
% Syntax:
%   S = nestStruct(S, fieldNames)
%
% Example:
%   S = nestStruct(struct("a", 1), ["one", "two"])
%
%   one:
%       two:
%           a : 1
%   S.one.two.a = 1

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    arguments
        S           (1,1)       struct
        fieldNames              string
    end

    for i = numel(fieldNames):-1:1
        S = struct(fieldNames(i), S);
    end