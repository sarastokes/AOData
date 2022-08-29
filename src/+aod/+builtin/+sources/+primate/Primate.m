classdef Primate < aod.core.sources.Subject
    % PRIMATE
    %
    % Description:
    %   Subject class tailored for UR primates
    %
    % Parent:
    %   aod.core.sources.Subject
    %
    % Constructor:
    %   obj = Primate(name)
    %
    % Dependent properties:
    %   ID                      double, ID extracted from name
    % ---------------------------------------------------------------------
    
    properties (Dependent)
        ID
    end

    methods
        function obj = Primate(name, varargin)
            obj = obj@aod.core.sources.Subject(name, varargin{:});
        end

        function value = get.ID(obj)
            value = str2double(erase(obj.Name, 'MC'));
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = obj.Name;
        end
    end
end