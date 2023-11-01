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

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "bb3e0aa1-78ba-4b3c-a98f-24da159ec02b";
		end
    end
end