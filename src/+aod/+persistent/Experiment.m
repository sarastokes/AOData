classdef Experiment < aod.persistent.Entity & dynamicprops
% EXPERIMENT
%
% Description:
%   Represents a persisted Experiment in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = Experiment(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Experiment
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        homeDirectory           char
        experimentDate(1,1)     datetime
        epochIDs

        AnalysesContainer         
        EpochsContainer        
        SourcesContainer                 
        SegmentationsContainer                 
        CalibrationsContainer            
        SystemsContainer                 
    end

    properties (Dependent)
        numEpochs
    end

    methods
        function obj = Experiment(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end

        function value = get.numEpochs(obj)
            value = numel(obj.epochIDs);
        end
    end

    methods
        function setHomeDirectory(obj, homeDirectory)
            % SETHOMEDIRECTORY
            %
            % Description:
            %   Change the experiment's home directory
            %
            % Syntax:
            %   setHomeDirectory(obj, homeDirectory)
            % -------------------------------------------------------------
            arguments
                obj
                homeDirectory           string
            end

            evtData = aod.persistent.events.DatasetEvent(...
                'homeDirectory', homeDirectory, obj.homeDirectory);
            notify(obj, 'DatasetChanged', evtData);

            obj.homeDirectory = homeDirectory;
        end
    end

    methods
        function addAnalysis(obj, analysis)
            % ADDANALYSIS
            % 
            % Description:
            %   Add an Analysis to the Experiment and the HDF5 file
            %
            % Syntax:
            %   addAnalysis(obj, analysis)
            % -------------------------------------------------------------
            arguments
                obj
                analysis        {mustBeA(analysis, 'aod.core.Analysis')}
            end

            analysis.setParent(obj);
            obj.addEntity(analysis);
        end

        function addCalibration(obj, calibration)
            % ADDCALIBRATION
            %
            % Description:
            %   Add a Calibration to the Experiment and the HDF5 file
            %
            % Syntax:
            %   addCalibration(obj, calibration)
            % -------------------------------------------------------------
            arguments
                obj
                calibration     {mustBeA(calibration, 'aod.core.Calibration')}
            end

            calibration.setParent(obj);
            obj.addEntity(calibration);
        end

        function addEpoch(obj, epoch)
            % ADDEPOCH
            %
            % Description:
            %   Add an Epoch to the Experiment and the HDF5 file
            %
            % Syntax:
            %   addEpoch(obj, epoch)
            % -------------------------------------------------------------
            arguments
                obj
                epoch           {mustBeA(epoch, 'aod.core.Epoch')}
            end

            epoch.setParent(obj);
            obj.addEntity(epoch);
        end

        function addSegmentation(obj, segmentation)
            % ADDSEGMENTATION
            %
            % Description:
            %   Add a Segmentation to the Experiment and the HDF5 file
            %
            % Syntax:
            %   addSegmentation(obj, segmentation)
            % -------------------------------------------------------------
            arguments
                obj
                segmentation    {mustBeA(segmentation, 'aod.core.Segmentation')}
            end

            segmentation.setParent(obj);
            obj.addEntity(segmentation);
        end

        function addSource(obj, source)
            % ADDSOURCE
            %
            % Description:
            %   Add a Source to the Experiment and the HDF5 file
            %
            % Syntax:
            %   addSource(obj, source)
            % -------------------------------------------------------------
            arguments
                obj
                source              {mustBeA(source, 'aod.core.Source')}
            end

            source.setParent(obj);
            obj.addEntity(source);
        end

        function addSystem(obj, system)
            % ADDSYSTEM
            %
            % Description:
            %   Add a System to the Experiment and the HDF5 file
            %
            % Syntax:
            %   addSystem(obj, system)
            % -------------------------------------------------------------
            arguments
                obj
                system      {mustBeA(system, 'aod.core.System')}
            end
            
            system.setParent(obj);
            obj.addEntity(system);
        end
    end

    methods (Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);
 
            obj.experimentDate = obj.loadDataset('experimentDate');
            obj.homeDirectory = obj.loadDataset('homeDirectory');
            obj.epochIDs = obj.loadDataset('epochIDs');
            obj.setDatasetsToDynProps();

            obj.setLinksToDynProps();

            obj.AnalysesContainer = obj.loadContainer('Analyses');
            obj.CalibrationsContainer = obj.loadContainer('Calibrations');
            obj.EpochsContainer = obj.loadContainer('Epochs');
            try
                obj.SegmentationsContainer = obj.loadContainer('Segmentations');
            catch
                obj.SegmentationsContainer = obj.loadContainer('Regions');
            end
            obj.SourcesContainer = obj.loadContainer('Sources');
            obj.SystemsContainer = obj.loadContainer('Systems');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Analyses(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).AnalysesContainer(idx));
            end
        end

        function out = Calibrations(obj, idx)
            if nargin < 2 
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).CalibrationsContainer(idx));
            end
        end

        function out = Epochs(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).EpochsContainer(idx));
            end
        end

        function out = Segmentations(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SegmentationsContainer(idx));
            end
        end

        function out = Sources(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SourcesContainer(idx));
            end
        end

        function out = Systems(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SystemsContainer(idx));
            end
        end
    end
end