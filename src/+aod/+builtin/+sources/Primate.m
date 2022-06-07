classdef Primate < aod.core.Subject
    % PRIMATE
    %
    % Description:
    %   Subject class tailored for UR primates
    % ---------------------------------------------------------------------
    
    properties
        fullID
    end

    methods
        function obj = Primate(ID, parent, varargin)
            obj = obj@aod.core.Subject(ID, parent, varargin{:});
        end

        function value = get.fullID(obj)
            value = ['201', num2str(floor(obj.ID/100)), num2str(rem(obj.ID/100))];
        end
    end

    methods (Access = protected)
        function value = getDisplayName(obj)
            value = ['MC', int2fixedwidthstr(obj.ID, 5)];
        end
    end
end