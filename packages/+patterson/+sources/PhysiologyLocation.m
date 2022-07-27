classdef PhysiologyLocation < aod.core.sources.Location 

    methods
        function obj = PhysiologyLocation(parent, locationName)
            
            if ischar(locationName)
                locationName = string(locationName);
            end

            % Determine whether location is one of the standard locations
            STANDARD_LOCATIONS = ["right", "bottom", "left", "top"];
            ID = find(obj.STANDARD_LOCATIONS == lower(locationName));
            if ~isempty(ID)
                locationName = STANDARD_LOCATIONS(ID);
            else
                locationName = "unknown";
            end

            obj = obj@aod.builtin.sources.Location(...
                parent, capitalize(locationName));

        end
    end