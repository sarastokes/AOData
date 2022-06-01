classdef Analysis < aod.core.Entity
% Analysis
%
% Description:
%   Implements data analysis. Meant to be expanded by subclasses
%
% -------------------------------------------------------------------------
    methods
        function obj = Analysis(parent)
            obj.allowableParentTypes = {'aod.core.Dataset', 'aod.core.Epoch', 'aod.core.Empty'};

            if nargin > 0
                obj.setParent(parent);
            end
        end
    end
end 