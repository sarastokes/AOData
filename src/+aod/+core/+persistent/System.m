classdef System < aod.core.persistent.Entity & dynamicprops

    methods
        function obj = System(hdfName, hdfPath, entityFactory)
            if nargin < 3
                entityFactory = [];
            end
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, entityFactory);
        end
    end

    methods (Access = protected)
        function populateEntityFromFile(obj)
            [dsetNames, linkNames] = populateEntityFromFile@aod.core.persistent.Entity(obj);

            if ~isempty(dsetNames)
                obj.setDatasetsToDynProps(dsetNames);
        end
    end
end