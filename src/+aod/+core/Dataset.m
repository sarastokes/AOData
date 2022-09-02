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
%   obj = Dataset(name)
%   obj = Dataset(name, data)
%
% Properties:
%   Data
%
% Sealed methods:
%   setData(obj, data)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data 
    end

    methods
        function obj = Dataset(name, data)
            obj = obj@aod.core.Entity(name);
            if nargin > 1
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