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

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Epoch'};
    end
    
    methods
        function obj = Stimulus(varargin)
            obj = obj@aod.core.Entity(varargin{:});
        end
    end
end
