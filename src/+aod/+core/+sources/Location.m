classdef Location < aod.core.Source
% A location imaged in an experiment
%
% Description:
%   An imaging location within an eye
%
% Parent:
%   aod.core.Source
%
% Constructor:
%   obj = aod.core.sources.Location(name)         

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Location(name, varargin)
            obj = obj@aod.core.Source(name, varargin{:});
        end
    end
end