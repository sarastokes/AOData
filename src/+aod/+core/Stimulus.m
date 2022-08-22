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
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------

    % properties (SetAccess = protected)
    %     stimParameters                      = aod.core.Parameters
    % end

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Epoch'};
        % parameterPropertyName = 'stimParameters';
    end
    
    methods
        function obj = Stimulus(parent)
            obj = obj@aod.core.Entity(parent);
        end
    end
end
