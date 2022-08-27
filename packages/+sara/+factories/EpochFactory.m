classdef EpochFactory < aod.core.Factory 

    methods
        function obj = EpochFactory()
            % Do nothing
        end

        function ep = get(obj, EXPT, epochID, epochType, source, system)

            ep = sara.Epoch(epochID, epochType);

            % Add to Experiment to facilitate relative file names and 
            % references to existing source/system entities
            EXPT.addEpoch(ep);
            % Set source and system
            ep.setSource(source);
            ep.setSystem(system);

            % Get the file names associated with this epoch
            EFM = sara.util.EpochFileManager(EXPT.homeDirectory);
            ep = EFM.populateFileNames(ep);

            % Add imaging parameters, if necessary
            if ep.hasFile('ImagingParams')
                reader = sara.readers.EpochParameterReader(ep.getFile('ImagingParams'));
                ep = reader.read(ep);
            end

            % Add registration, if necessary
            if ep.hasFile('RegMotion')
                reg = aod.builtin.registrations.StripRegistration();
                reg.loadData(ep.getFile('RegMotion'));
                reg.loadParameters(ep.getFile('RegParams'));
                ep.addRegistration(reg);
            end

            % Add stimuli, if necessary
            if epochType == sara.EpochTypes.SPECTRAL
                protocol = sara.factories.SpectralProtocolFactory.create(...
                    EXPT.getCalibration('sara.calibrations.MaxwellianView'),... 
                    ep.getParam('StimulusName'));
                stim = sara.stimuli.SpectralStimulus(protocol);
                stim.loadVoltages(ep.getFile('LedVoltages'));
                stim.loadFrames(ep.getFile('FrameTable'));
                ep.addStimulus(stim);
            elseif epochType == sara.EpochTypes.Spatial
                protocol = sara.factories.SpatialProtocolFactory.create(...
                    EXPT.getCalibration('sara.calibrations.TopticaNonlinearity'),...
                    ep.getParam('StimulusName'));
                stim = sara.stimuli.SpatialStimulus(protocol);
                ep.addStimulus(stim);
            end
        end
    end

    methods 
        function ep = addStripRegistration(ep)
            if ep.hasFile('RegMotion')
                reg = aod.builtin.registrations.StripRegistration();
                reg.loadData(ep.getFile('RegMotion'));
                reg.loadParameters(ep.getFile('RegParams'));
                ep.addRegistration(reg);
            end
        end
    end

    methods (Static)
        function EXPT = create(obj, EXPT, epochIDs, epochType, source, system)
            obj = sara.factories.EpochFactory();

            for i = 1:numel(epochIDs)
                EXPT = obj.get(EXPT, epochIDs(i), epochType, source, system);
            end
        end
    end
end 