classdef PhysiologyLocation < aod.core.sources.Location 

    properties (SetAccess = private)
        avgImage
    end

    methods
        function obj = PhysiologyLocation(parent, locationName)
            
            if ischar(locationName)
                locationName = string(locationName);
            end

            % Determine whether location is one of the standard locations
            STANDARD_LOCATIONS = ["right", "bottom", "left", "top"];
            ID = find(STANDARD_LOCATIONS == lower(locationName));
            if ~isempty(ID)
                locationName = STANDARD_LOCATIONS(ID);
            else
                locationName = "unknown";
            end

            obj = obj@aod.core.sources.Location(...
                parent, capitalize(locationName));

        end

        function setAvgImage(obj, avgImage)
            if ischar(obj.avgImage)
                obj.avgImage = imread(avgImage);
            else
                obj.avgImage = avgImage;
            end
        end
    end
end