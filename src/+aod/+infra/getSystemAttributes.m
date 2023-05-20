function out = getSystemAttributes()
% Returns attributes reserved by AOData
%
% Description:
%   Returns all attributes that are defined by AOData instead of the user.
%   There are two groups of system attributes, those used by
%   h5-tools-matlab and those that are properties of aod.core.Entity
%
% Syntax:
%   out = aod.infra.getSystemAttributes()
%   
% See also:
%   aod.h5.getPersistedProperties

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    out = ["Class", "UUID", "EntityType",... 
        "EnumClass", "Format", "ColumnClass",...
        "LastModified", "label", "DateCreated"];
