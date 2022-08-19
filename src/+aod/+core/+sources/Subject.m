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
%   obj = aod.core.sources.Subject(parent, name, varargin)
%
% Parameters:
%   Species
%   Sex
%   Age
%   Demographics
%
% Inherited properties:
%   name
%   sourceParameters
% -------------------------------------------------------------------------

    methods 
        function obj = Subject(parent, name, varargin)
            obj@aod.core.Source(parent, name);

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