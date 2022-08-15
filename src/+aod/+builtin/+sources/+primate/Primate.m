classdef Primate < aod.core.sources.Subject
    % PRIMATE
    %
    % Description:
    %   Subject class tailored for UR primates
    %
    % Inherited properties:
    %   sourceParameters        aod.core.Parameters
    % Dependent properties:
    %   ID                      double, ID extracted from name
    % ---------------------------------------------------------------------
    
    properties (Hidden, Dependent)
        ID
    end

    methods
        function obj = Primate(parent, name, varargin)
            obj = obj@aod.core.sources.Subject(parent, name);
        end

        function value = get.ID(obj)
            value = str2double(erase(obj.name, 'MC'));
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = obj.name;
        end
    end
end