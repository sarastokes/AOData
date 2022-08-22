classdef Dataset < aod.core.Entity & matlab.mixin.Heterogeneous
% DATASET
%
% Description:
%   Miscellaneous datasets associated with an Epoch
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Dataset(parent)
%   obj = Dataset(parent, data)
%
% Properties:
%   Name
%   Data
%
% Sealed methods:
%   setName(obj, name)
%   setData(obj, data)
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Name(1,:)               char
        Data 
    end

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Epoch'}
    end

    methods
        function obj = Dataset(parent, name, data)
            obj = obj@aod.core.Entity(parent);
            obj.setName(name);
            if nargin > 2
                obj.setData(data);
            end
        end
    end

    methods (Sealed)
        function setName(obj, name)
            arguments
                obj
                name        char
            end
            obj.Name = name;
        end
    end

    methods (Sealed, Access = protected)
        function setData(obj, data)
            obj.Data = data;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            if ~isempty(obj.Name)
                value = obj.Name;
            else
                value  = 'Dataset';
            end
        end
    end
end