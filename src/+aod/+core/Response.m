classdef Response < aod.core.Entity & matlab.mixin.Heterogeneous
% A response extracted from data acquired during an epoch
%
% Description:
%   A response extracted from data acquired during an Epoch
%
% Parent: 
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.Response(name)
%
% Properties:
%   Data 
%   dateCreated
%
% Methods:
%   setData(obj, data)
%   addTiming(obj, timing)
%   clearTiming(obj)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data                             
        Timing                             
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

        function clearTiming(obj)
            % CLEARTIMING
            %
            % Syntax:
            %   clearTiming(obj)
            % -------------------------------------------------------------
            obj.Timing = [];
        end
    end

    methods (Access = protected)
        function sync(obj)
            sync@aod.core.Entity(obj);
            if isempty(obj.Timing) && ~isempty(obj.Parent.Timing)
                obj.Timing = obj.Parent.Timing;
            end
        end
    end
end