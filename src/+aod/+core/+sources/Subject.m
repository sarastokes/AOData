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
    
    methods (Access = protected)
        function value = specifyAttributes(obj)
            value = specifyAttributes@aod.core.Entity(obj);

            value.add('Species', string.empty(), @isstring,...
                'Species of the subject');
            value.add('Sex', string.empty(),... 
                @(x) ismember(x, ["male", "female", "unknown"]),...
                'Sex of the subject');
            value.add('Age', string.empty(), @(x) isdatetime | isstring,...
                'Age of the subject in years');
            value.add('Demographics', string.empty(), @isstring,...
                'Additional demographic information about the subject');
        end 
    end
end