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
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);
 
            obj.experimentDate = obj.loadDataset(dsetNames, 'experimentDate');
            obj.homeDirectory = obj.loadDataset(dsetNames, 'homeDirectory');
            obj.epochIDs = obj.loadDataset(dsetNames, 'epochIDs');
            obj.setDatasetsToDynProps(dsetNames);

            obj.setLinksToDynProps(linkNames);

            obj.Analyses = obj.loadContainer('Analyses');
            obj.Calibrations = obj.loadContainer('Calibrations');
            obj.Epochs = obj.loadContainer('Epochs');
            obj.Regions = obj.loadContainer('Regions');
            obj.Sources = obj.loadContainer('Sources');
            obj.Systems = obj.loadContainer('Systems');
        end
    end
end