classdef Subject < aod.core.Source 
% SUBJECT
%
% Description:
%   Top-level source of data in experiment (e.g. mouse, human, model eye)
%
% Parent:
%   aod.core.Source
%
% Constructor:
%   obj = aod.core.sources.Subject(name)
%   obj = aod.core.sources.Subject(name, 'Species', value, 'Sex', value,...
%       'Age', value, 'Demographics', value)
%
% Parameters:
%   Species
%   Sex
%   Age
%   Demographics
% -------------------------------------------------------------------------

    methods 
        function obj = Subject(name, varargin)
            obj@aod.core.Source(name);

            ip = aod.util.InputParser();
            addParameter(ip, 'Species', [], @ischar);
            addParameter(ip, 'Sex', 'unknown',... 
                @(x) ismember(lower(x), {'male', 'female', 'unknown'}));
            addParameter(ip, 'Age', [], @isnumeric);
            addParameter(ip, 'Demographics', [], @ischar);
            parse(ip, varargin{:});

            obj.setParam(ip.Results);
        end
    end
end