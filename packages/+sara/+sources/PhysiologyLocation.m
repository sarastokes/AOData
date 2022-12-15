classdef PhysiologyLocation < aod.core.sources.Location 
% PHYSIOLOGYLOCATION
%
% Constructor:
%   obj = PhysiologyLocation(parent, name)
%
% Note:
%   Allowed locations: right, bottom, left, top
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        avgImage
    end

    methods
        function obj = PhysiologyLocation(name)
            
            if ischar(name)
                name = string(name);
            end

            % Determine whether location is one of the standard locations
            STANDARD_LOCATIONS = ["right", "bottom", "left", "top"];
            ID = find(STANDARD_LOCATIONS == lower(name));
            if ~isempty(ID)
                name = STANDARD_LOCATIONS(ID);
            else
                warning('PhysiologyLocation: Unidentified location %s', name);
                name = "unknown";
            end

            obj = obj@aod.core.sources.Location(char(appbox.capitalize(name)));
        end

        function setImage(obj, avgImage)
            if ischar(avgImage)
                obj.avgImage = imread(avgImage);
            else
                obj.avgImage = avgImage;
            end
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            if ~isempty(obj.Parent)
                value = [obj.Parent.label, obj.Name(1)];
            else
                value = obj.Name;
            end
        end
    end
end