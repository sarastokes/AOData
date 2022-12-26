classdef EpochFactory < aod.util.Factory 

    methods
        function obj = EpochFactory()
            % Do nothing
        end

        function ep = get(~, EXPT, epochID, epochType, source, system)

            if epochType == sara.EpochTypes.BACKGROUND
                ep = sara.epochs.BackgroundEpoch(epochID);
            else
                ep = sara.Epoch(epochID, epochType);
            end
            EXPT.add(ep);

            % Set source and system
            ep.setSource(source);
            ep.setSystem(system);

            % Get the file names associated with this epoch
            EFM = sara.util.EpochFileManager(EXPT.homeDirectory);
            ep = EFM.populateFileNames(ep);

            % Get the epoch timing
            if ep.hasFile('FrameTable')
                if epochType == sara.EpochTypes.SPATIAL
                    reader = sara.readers.SpatialFrameTableReader(...
                        ep.getExptFile('FrameTable'));
                else
                    reader = sara.readers.FrameTableReader(...
                        ep.getExptFile('FrameTable'));
                end
                ep.setTiming(reader.readFile());
            end

            % Add imaging parameters, if necessary
            if ep.hasFile('ImagingParams')
                reader = sara.readers.EpochParameterReader(ep.getExptFile('ImagingParams'));
                ep = reader.readFile(ep);
            end
            
            % Add stimuli defined in epoch parameters
            if epochType.isPhysiology()
                if hasParam(ep, 'AOM1')
                    stim = sara.stimuli.Mustang(ep.getParam('AOM1'));
                    ep.add(stim);
                end
            end

            % Add registration, if necessary
            if ep.hasFile('RegMotion')
                reg = aod.builtin.registrations.StripRegistration();
                reg.loadData(ep.getExptFile('RegMotion'));
                reg.loadParameters(ep.getExptFile('RegParams'));
                ep.add(reg);
            end

            % Add stimuli, if necessary
            if epochType == sara.EpochTypes.SPECTRAL
                protocol = sara.factories.SpectralProtocolFactory.create(...
                    EXPT.get('Calibration', {'Class', 'sara.calibrations.MaxwellianView'}),... 
                    ep.getParam('StimulusName'));
                stim = sara.stimuli.SpectralStimulus(protocol);
                stim.loadVoltages(ep.getExptFile('LedVoltages'));
                stim.loadFrames(ep.getExptFile('FrameTable'));
                ep.add(stim);
            elseif epochType == sara.EpochTypes.SPATIAL
                protocol = sara.factories.SpatialProtocolFactory.create(...
                    EXPT.getCalibration('sara.calibrations.TopticaNonlinearity'),...
                    ep.getParam('StimulusName'));
                stim = sara.stimuli.SpatialStimulus(protocol);
                ep.add(stim);
            end
        end
    end

    methods 
        function ep = addStripRegistration(ep)
            if ep.hasFile('RegMotion')
                reg = aod.builtin.registrations.StripRegistration();
                reg.loadData(ep.getExptFile('RegMotion'));
                reg.loadParameters(ep.getExptFile('RegParams'));
                ep.add(reg);
            end
        end
    end

    methods (Static)
        function EXPT = create(EXPT, epochIDs, epochType, source, system)
            obj = sara.factories.EpochFactory();

            for i = 1:numel(epochIDs)
                obj.get(EXPT, epochIDs(i), epochType, source, system);
            end
        end
    end
end 