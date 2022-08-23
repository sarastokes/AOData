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
%   Data
%
% Sealed methods:
%   setData(obj, data)
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data 
    end

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Epoch'}
    end

    methods
        function obj = Dataset(parent, name, data)
            obj = obj@aod.core.Entity(parent, name);
            if nargin > 2
                obj.setData(data);
            end
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