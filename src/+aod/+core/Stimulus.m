classdef Stimulus < aod.core.Entity & matlab.mixin.Heterogeneous
% STIMULUS
%
% Description:
%   A stimulus presented during an Epoch
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
% 
% Constructor:
%   obj = aod.core.Stimulus(parent)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Epoch'};
    end
    
    methods
        function obj = Stimulus(parent, name)
            if nargin < 1
                name = [];
            end
            obj = obj@aod.core.Entity(parent);
        end
    end
end
