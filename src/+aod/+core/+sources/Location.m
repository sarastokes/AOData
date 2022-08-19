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
%   obj = Location(parent, name)
%
% Inherited properties:
%   name   
%   sourceParameters          
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