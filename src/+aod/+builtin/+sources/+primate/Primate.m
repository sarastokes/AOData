classdef Primate < aod.core.sources.Subject
    % PRIMATE
    %
    % Description:
    %   Subject class tailored for UR primates
    %
    % Inherited properties:
    %   sourceParameters        aod.core.Parameters
    % Dependent properties:
    %   dcmID                   ID formatted to match DCM's style
    % ---------------------------------------------------------------------
    
    properties (Hidden, Dependent)
        dcmID
    end

    methods
        function obj = Primate(ID, parent, varargin)
            obj = obj@aod.core.sources.Subject(ID, parent);


            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Species', [], @ischar);
            addParameter(ip, 'Sex', [], @ischar);
            addParameter(ip, 'Age', [], @isnumeric);
            addParameter(ip, 'Demographics', [], @ischar);
            parse(ip, varargin{:});

            obj.addParameter(ip.Results);
        end

        function value = get.dcmID(obj)
            value = ['201', num2str(floor(obj.ID/100)), num2str(rem(obj.ID/100))];
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = ['MC', int2fixedwidthstr(obj.ID, 5)];
        end
    end
end