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
    % Parameters:
    %   DateOfBirth
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

            if ~obj.hasParam('DateOfBirth')
                obj.setParam('Age', round(years(datetime('now') - obj.getParam('DateOfBirth')),1));
            end
        end

        function value = get.ID(obj)
            value = str2double(erase(obj.Name, 'MC'));
        end
    end

    methods (Access = protected)
        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.core.sources.Subject(obj);

            value.add('DateOfBirth', [], @isdatetime,...
                'Date of birth of the subject');
        end
    end
end