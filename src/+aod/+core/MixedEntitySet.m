classdef MixedEntitySet < handle & matlab.mixin.CustomDisplay


    methods
        function obj = MixedEntitySet()
            % Switch defaults to core interface
            obj.entityClass = 'aod.core.Entity';
            
            obj.Experiments = aod.core.Experiment.empty();
            obj.Sources = aod.core.Source.empty();
            obj.Systems = aod.core.System.empty();
            obj.Channels = aod.core.Channel.empty();
            obj.Devices = aod.core.Device.empty();
            obj.Calibrations = aod.core.Calibration.empty();
            obj.Epochs = aod.core.Epoch.empty();
            obj.EpochDatasets = aod.core.EpochDataset.empty();
            obj.Registrations = aod.core.Registration.empty();
            obj.Responses = aod.core.Response.empty();
            obj.Stimuli = aod.core.Stimulus.empty();
            obj.ExperimentDatasets = aod.core.ExperimentDataset.empty();
            obj.Annotations = aod.core.Annotation.empty();
            obj.Analyses = aod.core.Analysis.empty();
        end
    end
end 