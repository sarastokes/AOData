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

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "25d825e0-46ce-4e14-a6a8-b9e70770909c";
		end
    end
end