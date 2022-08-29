classdef Location < aod.core.Source
% LOCATION
%
% Description:
%   An imaging location within an eye
%
% Parent:
%   aod.core.Source
%
% Constructor:
%   obj = Location(name)         
% -------------------------------------------------------------------------

    methods
        function obj = Location(name)
            obj = obj@aod.core.Source(name);
        end
    end
end