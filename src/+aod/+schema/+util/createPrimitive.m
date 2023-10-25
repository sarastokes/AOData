function primitive = createPrimitive(primitiveType, name, parent, varargin)
% CREATEPRIMITIVE
%
% Description:
%   Create and populate a Primitive
%
% Syntax:
%   primitive = aod.schema.util.createPrimitive(primitiveType, name, varargin)
%
% Inputs:
%   primitiveType       string/char or aod.schema.primitives.PrimitiveType
%   name                string
% Optional inputs:
%   parent              aod.schema.Entry
% Any options defined by the chosen primitiveType can be passed as well
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        primitiveType
        name                (1,1)   string
        parent                              = []
    end

    arguments (Repeating)
        varargin
    end

    createFcn = aod.schema.primitives.PrimitiveTypes.getFcnHandle(primitiveType);
    primitive = createFcn(name, parent, varargin{:});