classdef Location < aod.core.Source
% LOCATION
%
% Description:
%   An imaging location within an eye
%
% Constructor:
%   obj = Location(parent, identifier)
%
% Properties:
%   identifier              Some way of labeling the location
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        identifier
    end

    methods
        function obj = Location(parent, identifier)
            obj = obj@aod.core.Source(parent);
            obj.identifier = identifier;
        end
    end
end