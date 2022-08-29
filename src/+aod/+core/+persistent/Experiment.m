classdef Experiment < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        homeDirectory           char
        experimentDate(1,1)     datetime

        Epochs                  aod.core.Epoch
        Sources                 aod.core.Source
        Regions                 aod.core.Region
        Calibrations            aod.core.Calibration
        Systems                 aod.core.System
    end

    properties (Dependent)
        epochIDs
        numEpochs
    end

    methods
        function obj = Experiment(hdfName, hdfPath, entityFactory)
            if nargin < 3
                entityFactory = [];
            end
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, entityFactory);
        end
        
        function value = get.epochIDs(obj)
            value = [];
        end

        function value = get.numEpochs(obj)
            value = [];
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

            if ismember("experimentDate", datasetNames)
                obj.experimentDate = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, 'experimentDate');
            end
            if ismember("homeDirectory", datasetNames)
                obj.homeDirectory = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, 'homeDirectory');
            end
            
            obj.setDatasetsToDynProps(datasetNames);
        end
    end
end