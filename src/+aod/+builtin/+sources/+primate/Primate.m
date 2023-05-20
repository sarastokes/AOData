classdef Primate < aod.core.sources.Subject
% Non-human primate
%
% Description:
%   Subject class tailored for NHPs
%
% Parent:
%   aod.core.sources.Subject
%
% Constructor:
%   obj = aod.core.sources.Primate(name)
%
% Attributes:
%   DateOfBirth
%
% Dependent properties:
%   ID                      double, ID extracted from name
%
%! Move to sara-aodata-package

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    
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
        function value = specifyAttributes(obj)
            value = specifyAttributes@aod.core.sources.Subject(obj);

            value.remove('Age');
            value.add('DateOfBirth', datetime.empty(), @isdatetime,...
                'Date of birth of the subject');
        end
    end
end