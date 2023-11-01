classdef SchemaTypes
% SCHEMATYPES
%
% Description:
%   Enumeration of different schema types that can be compared

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    enumeration
        % Schema types for a Record's Primitive
        PRIMITIVE
        VALIDATOR
        DECORATOR
        DEFAULT
        % Schema types for a Container's Primitives
        ITEM
        ITEM_PRIMITIVE
        ITEM_VALIDATOR
        ITEM_DECORATOR
        ITEM_DEFAULT
    end
end