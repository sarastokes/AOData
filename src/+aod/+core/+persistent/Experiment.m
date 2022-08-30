classdef Experiment < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        homeDirectory           char
        experimentDate(1,1)     datetime
        epochIDs

        Analyses                
        Epochs                  
        Sources                 
        Regions                 
        Calibrations            
        Systems                 
    end

    properties (Dependent)
        numEpochs
    end

    methods
        function obj = Experiment(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end

        function value = get.numEpochs(obj)
            value = max(size(obj.Epochs));
        end
    end

    methods (Access = protected)
        function populate(obj)
            [datasetNames, linkNames] = populate@aod.core.persistent.Entity(obj);

            if ismember("experimentDate", datasetNames)
                obj.experimentDate = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, 'experimentDate');
            end

            if ismember("homeDirectory", datasetNames)
                obj.homeDirectory = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, 'homeDirectory');
            end
            
            obj.setDatasetsToDynProps(datasetNames);
            obj.setLinksToDynProps(linkNames);

            % Create containers
            obj.Analyses = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Analyses'), obj.factory);
            obj.Calibrations = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Calibrations'), obj.factory);
            obj.Epochs = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Epochs'), obj.factory);
            obj.Regions = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Regions'), obj.factory);
            obj.Sources = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Sources'), obj.factory);
            obj.Systems = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Systems'), obj.factory);
        end
    end
end