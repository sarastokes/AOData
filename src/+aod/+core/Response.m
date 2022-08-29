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
% Methods:
%   setData(obj, data)
%   addTiming(obj, timing)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data                             
        Timing                              aod.core.Timing
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Epoch'};
    end

    methods
        function obj = Response(name)
            obj = obj@aod.core.Entity(name);
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
            %   addTiming(obj, timing)
            % -------------------------------------------------------------
            obj.Timing = timing;
        end
    end

    methods (Access = protected)
        function sync(obj)
            if isempty(obj.Timing) & ~isempty(obj.Parent.Timing)
                obj.Timing = obj.Parent.Timing;
            end
        end
    end
end