classdef Response < aod.core.Entity & matlab.mixin.Heterogeneous
% RESPONSE
%
% Description:
%   A response measured during an Epoch
%
% Parent: 
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Properties:
%   Data 
%   dateCreated
%
% Dependent properties:
%   Experiment 
%
% Methods:
%   setData(obj, data)
%   setTiming(obj, timing)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data                             
        Timing                              aod.core.Timing
    end

    properties (Hidden, Dependent)
        Experiment
    end

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Epoch'};
    end

    methods
        function obj = Response(parent, name)
            if nargin < 1
                name = [];
            end
            obj = obj@aod.core.Entity(parent);
        end

        function value = get.Experiment(obj)
            value = obj.ancestor('aod.core.Experiment');
        end
    end

    methods (Sealed)
        function setData(obj, data)
            % SETDATA
            %
            % Syntax:
            %   setData(obj, data)
            % -------------------------------------------------------------
            obj.Data = data;
        end

        function setTiming(obj, timing)
            % SETTIMING
            %
            % Syntax:
            %   obj.setTiming(timing)
            % -------------------------------------------------------------
            obj.Timing = timing;
        end
    end
end