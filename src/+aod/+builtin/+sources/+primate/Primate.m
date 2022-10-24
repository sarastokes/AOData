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

            ip = aod.util.InputParser();
            addParameter(ip, 'DateOfBirth', [], @(x) isdatetime(x) || istext(x));
            parse(ip, varargin{:});

            if istext(ip.Results.DateOfBirth)
                obj.setParam('DateOfBirth') = getDateYMD(ip.Results.DateOfBirth);
            else
                obj.setParam('DateOfBirth') = ip.Results.DateOfBirth;
            end

            if ~isempty(ip.Results.DateOfBirth)
                obj.setParam('Age') = round(years(datetime('now') - obj.getParam('DateOfBirth')),1);
            end
        end

        function value = get.ID(obj)
            value = str2double(erase(obj.Name, 'MC'));
        end
    end
end