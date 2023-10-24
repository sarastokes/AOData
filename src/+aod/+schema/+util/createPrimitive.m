function primitive = createPrimitive(primitiveType, name, varargin)
% CREATEPRIMITIVE
%
% Description:
%   Create and populate a Primitive
%
% Syntax:
%   primitive = aod.schema.util.createPrimitive(primitiveType, name, varargin)
%
% Inputs:
%   primitiveType
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    primitiveEnum = aod.schema.primitives.PrimitiveTypes.get(primitiveType);
    primitive = primitiveEnum.create(name, varargin{:});