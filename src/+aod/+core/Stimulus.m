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

    properties (SetAccess = protected)
        stimParameters                      = aod.core.Parameters
    end
    
    methods
        function obj = Stimulus(parent)
            obj = obj@aod.core.Entity();
            obj.allowableParentTypes = {'aod.core.Epoch'};
            obj.setParent(parent);
        end
    end

    methods (Sealed, Access = {?aod.core.Stimulus, ?aod.core.Creator})
        function addParameter(obj, paramName, paramValue)
            % ADDPARAMETER
            %
            % Syntax:
            %   addParameter(obj, paramName, paramValue)
            % -------------------------------------------------------------
            obj.stimParameters(paramName) = paramValue;
        end
    end
end
