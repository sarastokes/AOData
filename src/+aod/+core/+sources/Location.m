classdef Location < aod.core.Source
% LOCATION
%
% Description:
%   An imaging location within an eye
%
% Constructor:
%   obj = Location(parent, name)
%
% Properties:
%   name             
% -------------------------------------------------------------------------

    methods
        function obj = Location(parent, name)
            obj = obj@aod.core.Source(parent, name);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = obj.name;
        end
    end

end