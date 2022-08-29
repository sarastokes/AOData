classdef Device < aod.core.persistent.Entity & dynamicprops

    methods
        function obj = Device(hdfName, hdfPath, entityFactory)
            if nargin < 3
                entityFactory = [];
            end
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, entityFactory);
        end
    end

    methods (Access = protected)
        function populateEntityFromFile(obj)
            populateEntityFromFile@aod.core.persistent.Entity(obj);
            
            if ~isempty(obj.info.Datasets)
                datasetNames = string({obj.info.Datasets.Name});
            end
            if ~isempty(obj.info.Links)
                linkNames = string({obj.info.Links.Name});
                disp(linkNames)
            end

            if ~isempty(datasetNames)
                obj.setDatasetsToDynProps(datasetNames);
            end
        end
    end
end