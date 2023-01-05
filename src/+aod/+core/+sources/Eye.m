classdef Eye < aod.core.Source 
% An eye imaged in an experiment
%
% Description:
%   An eye within a Subject
%
% Parent:
%   aod.core.Source
%
% Constructor:
%   obj = aod.core.sources.Eye(name)
%
% Note:
%   Name is restricted to either 'OD' or 'OS'      

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Eye(name, varargin)
            % Validate user-defined name
            name = convertCharsToStrings(name);
            assert(ismember(name, ["OD", "OS"]),... 
                'Eye name must be OS or OD');

            obj = obj@aod.core.Source(name, varargin{:});
        end
    end
end