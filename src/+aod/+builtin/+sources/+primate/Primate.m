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

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "f51f688c-86b1-4503-a5db-5cda7139ffcc";
		end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.sources.Subject();

            value.remove("Age");
            value.add("DateOfBirth", "DATETIME",...
                "Size", "(1,1)",...
                "Description", "Date of birth of the subject");
        end

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.sources.Subject(value);

            value.set("ID", "TEXT",...
                "Size", "(1,1)",...
                "Description", "A comprehensive identifier with parent source(s) appended");
        end
    end
end