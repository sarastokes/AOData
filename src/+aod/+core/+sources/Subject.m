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
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();

            value.add("Species",...
                "Class", "string", "Size", [1 1],...
                "Description", "Species of the subject");
            value.add("Sex",...
                "Class", "string", "Default", "unknown",...
                "Function", @(x) ismember(x, ["male", "female", "unknown"]),...
                "Description", "Sex of the subject");
            value.add("Age",...
                "Class", "double", "Size", [1 1], "Units", "years",...
                "Function", @(x) mustBePositive(x),...
                "Description", "Age of the subject in years");
            value.add("Demographics",...
                "Class", "string", "Size", [1 1],...
                "Description", "Additional demographic information about the subject");
        end 
    end
end