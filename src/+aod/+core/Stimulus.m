classdef Stimulus < aod.core.Entity
% STIMULUS
% 
% Constructor:
%   obj = aod.core.Stimulus(parent)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        stimParameters                      % aod.core.Parameters
    end
    
    methods
        function obj = Stimulus(parent)
            obj = obj@aod.core.Entity();
            obj.allowableParentTypes = {'aod.core.Epoch', 'aod.core.Empty'};
            if nargin == 1 && ~isempty(parent)
                obj.setParent(parent);
            end
            obj.stimParameters = aod.core.Parameters();
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
