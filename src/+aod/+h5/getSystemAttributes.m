function out = getSystemAttributes()
% Returns attributes reserved by AOData
%
% Description:
%   Returns all attributes that are defined by AOData instead of the user
%
% Syntax:
%   out = getSystemAttributes()

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    out = ["Class", "UUID", "EntityType",... 
        "EnumClass", "Format", "ColumnClass",...
        "LastModified", "label"];
