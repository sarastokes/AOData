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
%   responseParameters
%   dateCreated
%
% Dependent properties:
%   Experiment 
%
% Methods:
%   addParameter(obj, paramValue, paramName)
%   setData(obj, data)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data                             
        Timing                              % aod.core.Timing
        responseParameters                  = aod.core.Parameters
    end

    properties (Hidden, Dependent)
        Experiment
    end

    methods
        function obj = Response(parent)
            obj.allowableParentTypes = {'aod.core.Epoch'};
            if nargin > 0
                obj.setParent(parent);
            end
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
        
        function addParameter(obj, varargin)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, value)
            %   obj.addParameter(paramName, value, paramName, value)
            %   obj.addParameter(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    obj.responseParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.responseParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
        end
    end
end