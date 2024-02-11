function primitive = createPrimitive(parent, primitiveType, varargin)
% CREATEPRIMITIVE
%
% Description:
%   Create and populate a Primitive
%
% Syntax:
%   primitive = aod.schema.util.createPrimitive(parent, primitiveType, varargin)
%
% Inputs:
%   primitiveType       string/char or aod.schema.primitives.PrimitiveType
%   name                string
% Optional inputs:
%   parent              aod.schema.Record
% Any options defined by the chosen primitiveType can be passed as well
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        parent
        primitiveType
    end

    arguments (Repeating)
        varargin
    end

    createFcn = aod.schema.PrimitiveTypes.getFcnHandle(primitiveType);
    primitive = createFcn(parent, varargin{:});