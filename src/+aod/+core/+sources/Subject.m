classdef Subject < aod.core.Source
% A subject imaged in an experiment
%
% Description:
%   Top-level source of data in experiment (e.g. mouse, human, model eye)
%
% Parent:
%   aod.core.Source
%
% Constructor:
%   obj = aod.core.sources.Subject(name)
%   obj = aod.core.sources.Subject(name,...
%       'Species', "value", 'Sex', "value",...
%       'Age', value, 'Demographics', "value")
%
% Attributes:
%   Species             string
%       Species of the subject
%   Sex                 "male", "female", "unknown"
%       Sex of the subject
%   Age                 numeric
%       Age of the subject in years
%   Demographics        string
%       Additional demographic information about the subject

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Subject(name, varargin)
            obj@aod.core.Source(name, varargin{:});
        end
    end

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "1aef2f9e-9fc1-4b06-a0b8-434576512cf7";
		end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();

            value.add("Species", "TEXT",...
                "Size", "(1,1)",...
                "Description", "Species of the subject");
            value.add("Sex", "TEXT",...
                "Default", "unknown", "Size", "(1,1)",...
                "Enum", ["male", "female", "unknown"],...
                "Description", "Sex of the subject");
            value.add("Age", "NUMBER",...
                "Minimum", 0, "Size", "(1,1)", "Units", "years",...
                "Description", "Age of the subject in years");
            value.add("Demographics", "TEXT",...
                "Size", "(1,:)",...
                "Description", "Additional demographic information about the subject");
        end
    end
end