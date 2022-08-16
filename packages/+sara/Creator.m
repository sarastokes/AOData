classdef Creator < aod.core.Creator

    properties (SetAccess = private)
        Experiment
    end

    methods
        function obj = Creator(homeDirectory)
            obj@aod.core.Creator(homeDirectory);
        end

        function createExperiment(obj, expDate, source, location, varargin)
            
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'Purpose', [], @istext);
            parse(ip, varargin{:});
            

            obj.Experiment = sara.experiments.PhysiologyExperiment(...
                obj.homeDirectory, expDate, location);
            obj.Experiment.addSource(source);
            if ~isempty(ip.Results.Purpose)
                obj.Experiment.setDescription(ip.Results.Purpose);
            end
            obj.Experiment.initParameters(ip.Unmatched);
        end

        function addEpochs(obj, epochIDs, epochType, source, varargin)
            % ADDEPOCHS
            %
            % Syntax:
            %   obj.addEpochs(epochIDs, epochType, source, varargin)
            % -------------------------------------------------------------
            if isempty(epochType)
                epochType = sara.EpochTypes.Unknown;
            end

            fprintf('Adding epochs... ');
            for i = 1:numel(epochIDs)
                ep = obj.makeEpoch(epochIDs(i), epochType, source, varargin{:});          
                obj.Experiment.addEpoch(ep);
                fprintf('%u ', epochIDs(i));
            end
            obj.Experiment.sortEpochs();
            if epochType.isPhysiology()
                obj.Experiment.populateStimSummaries();
            end
            fprintf('\nDone.\n')
        end

        function addCalibration(obj, calibration)
            % ADDCALIBRATION
            %
            % Syntax:
            %   obj.addCalibration(calibration)
            % -------------------------------------------------------------
            if isempty(calibration.Parent) || isa(calibration.Parent, 'aod.calibrations.Empty')
                calibration.setParent(obj.Experiment);
            end
            obj.Experiment.addCalibration(calibration);
        end

        function clearCalibrations(obj)
            % CLEARCALIBRATIONS
            %
            % Syntax:
            %   obj.clearCalibrations()
            % -------------------------------------------------------------
            obj.Experiment.clearCalibrations();
        end
        
        function addSystem(obj, system)
            % ADDSYSTEM
            %
            % Syntax:
            %   obj.addSystem(system)
            % -------------------------------------------------------------
            if isempty(system.Parent)
                system.setParent(obj.Experiment);
            end
            obj.Experiment.addSystem(system);
        end
    
        function addRegions(obj, fileName, imSize, UIDs)
            % ADDREGIONS
            %
            % Syntax:
            %   obj.addRegions(fileName, imSize, UIDs)
            % -------------------------------------------------------------

            [filePath, ~, ~] = fileparts(fileName);
            if isempty(filePath)
                fileName = fullfile(obj.Experiment.getAnalysisFolder(), fileName);
            end
            regions = aod.builtin.regions.Rois(obj.Experiment, fileName, imSize);
            if nargin > 3 && ~isempty(UIDs)
                regions.setRoiUIDs(UIDs);
            end
            obj.Experiment.addRegions(regions);
        end

        function addRigidTransform(obj, fName, epochIDs, varargin)
            % ADDRIGIDTRANSFORM
            %
            % Syntax:
            %   obj.addRigidTransform(fName, epochIDs, varargin)
            % -------------------------------------------------------------
            if ~isfile(fName)
                fName = fullfile(obj.Experiment.getAnalysisFolder(), fName);
            end
            reader = aod.builtin.readers.RigidTransformReader(fName);
            tforms = reader.read();

            for i = 1:numel(epochIDs)
                ep = obj.Experiment.id2epoch(epochIDs(i));
                reg = aod.builtin.registrations.RigidRegistration(...
                    ep, squeeze(tforms(:,:,i)), varargin{:});
                ep.addRegistration(reg);
                ep.addFile('SiftTransform', erase(fName, obj.homeDirectory));
            end
        end
    end

    methods (Access = protected)
        function ep = makeEpoch(obj, epochID, epochType, source, varargin)
            % MAKEEPOCH
            if epochType == sara.EpochTypes.Background
                ep = sara.epochs.BackgroundEpoch(obj.Experiment, epochID, source);
            else
                ep = sara.Epoch(obj.Experiment, epochID, source, epochType);
            end
            % Extract epoch imaging parameters
            if epochType.isPhysiology
                obj.extractEpochAttributes(ep);
            end
            % Extract filenames from experiment file
            obj.populateFileNames(ep);
            % If a registration report was found, add StripRegistration
            if ~isempty(ep.getFilePath('RegistrationReport'))
                obj.addStripRegistration(ep);
            end
            % Processing specific to spatial epochs
            if epochType == sara.EpochTypes.Spatial
                protocol = sara.factories.SpatialProtocolFactory.create(...
                    obj.Experiment.getCalibration('sara.calibrations.TopticaNonlinearity'),...
                    ep.getFilePath('TrialFile'));
                stimulus = sara.stimuli.SpatialStimulus(ep, protocol, varargin{:});
                ep.addStimulus(stimulus);
            end
            % Processing specific to spectral epochs
            if epochType == sara.EpochTypes.Spectral
                protocol = sara.factories.SpectralProtocolFactory.create(...
                    obj.Experiment.getCalibration('sara.calibrations.MaxwellianView'),...
                    ep.getFilePath('TrialFile'));
                stimulus = sara.stimuli.SpectralStimulus(ep, protocol, varargin{:});
                ep.addStimulus(stimulus);
            end
        end
    end

    methods (Access = protected)
        function fName = getAttributeFile(obj, ep)
            fName = sprintf('%u_%s_ref_%s.txt',...
                obj.Experiment.Sources(1).getParentID(), obj.Experiment.experimentDate,...
                int2fixedwidthstr(ep.ID, 4));
            fName = [obj.Experiment.homeDirectory, filesep, 'Ref', filesep, fName];
            if exist(fName, 'file')
                ep.addFile('Attributes', fName);
            else
                fName = [];
            end
        end

        function extractEpochAttributes(obj, ep)
            fName = obj.getAttributeFile(ep);
            if isempty(fName)
                return
            end

            txt = readProperty(fName, 'Date/Time = ');
            txt = erase(txt, ' (yyyy-mm-dd:hh:mm:ss)');
            ep.startTime = datetime(txt, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');

            % Additional file names
            ep.addFile('TrialFile', readProperty(fName, 'Trial file name = '));
            txt = strsplit(ep.files('TrialFile'), filesep);
            ep.addParameter('StimulusName', txt{end});

            txt = readProperty(fName, 'Scanner FOV = ');
            txt = erase(txt, ' (496 lines) degrees');
            txt = strsplit(txt, ' x ');
            ep.addParameter('FieldOfView', [str2double(txt{1}), str2double(txt{2})]);

            % Imaging window
            x = str2double(readProperty(fName, 'ImagingWindowX = '));
            y = str2double(readProperty(fName, 'ImagingWindowY = '));
            dx = str2double(readProperty(fName, 'ImagingWindowDX = '));
            dy = str2double(readProperty(fName, 'ImagingWindowDY = '));
            ep.addParameter('ImagingWindow', [x y dx dy]);

            % Channel parameters
            ep.addParameter('RefGain',... 
                str2double(readProperty(fName, 'ADC channel 1, gain = ')));
            ep.addParameter('VisGain',... 
                str2double(readProperty(fName, 'ADC channel 2, gain = ')));
            ep.addParameter('RefOffset',... 
                str2double(readProperty(fName, 'ADC channel 1, offset = ')));
            ep.addParameter('VisOffset',... 
                str2double(readProperty(fName, 'ADC channel 2, offset = ')));
            ep.addParameter('RefPmtGain',...
                str2double(readProperty(fName, 'Reflectance PMT gain  = ')));
            ep.addParameter('VisPmtGain',...
                str2double(readProperty(fName, 'Fluorescence PMT gain  = ')));
            
            mustangValue = str2double(readProperty(fName, 'AOM_VALUE1 = '));
            stim = sara.stimuli.Mustang(ep, mustangValue, '%');
            ep.addStimulus(stim);

            switch ep.epochType
                case sara.EpochTypes.Spatial
                    obj.extractSpatialAttributes(ep, fName);
                case sara.EpochTypes.Spectral
                    obj.extractSpectralAttributes(ep, fName);
            end
        end

        function extractSpectralAttributes(obj, ep, fName) %#ok<INUSL> 
            % EXTRACTSPECTRALATTRIBUTES
            %
            % Description:
            %   Extract attributes specific to spectral stimulus epochs
            % -------------------------------------------------------------
            % Reflectance window
            x = str2double(readProperty(fName, 'ReflectanceWindowX = '));
            y = str2double(readProperty(fName, 'ReflectanceWindowY = '));
            dx = str2double(readProperty(fName, 'ReflectanceWindowDX = '));
            dy = str2double(readProperty(fName, 'ReflectanceWindowDY = '));
            ep.addParameter('ReflectanceWindow', [x y dx dy]);

            % LED stimulus specifications
            ep.addParameter('LedInterval',...
                str2double(readProperty(fName, 'Interval value = ')));
            ep.addParameter('LedIntervalUnit',...
                readProperty(fName, 'Interval unit = '));
            
            % LUT files (may not be necessary with Calibration class)
            ep.addFile('LUT1', readProperty(fName, 'LUT1 = '));
            ep.addFile('LUT2', readProperty(fName, 'LUT2 = '));
            ep.addFile('LUT3', readProperty(fName, 'LUT3 = '));
        end

        function extractSpatialAttributes(obj, ep, fName) %#ok<INUSL> 
            % Video names
            ep.addFile('StimVideoName',...
                readProperty(fName, 'Stimulus video = '));
            ep.addFile('BackgroundVideoName',...
                readProperty(fName, 'Background video = '));
            
            % Stimulus location
            txt = readProperty(fName, 'Stimulus location in linear stabilized space = ');
            txt = erase(txt, '('); txt = erase(txt, ')');
            txt = strsplit(txt, ', ');
            ep.addParameter('StimulusLocation', [str2double(txt{1}), str2double(txt{2})]);
            
            % Power modulation 
            ep.addParameter('PowerModulation',... 
                convertYesNo(readProperty(fName, 'Stimulus power modulation = ')));
        end

        function populateFileNames(obj, ep)
            epochID = ep.ID;
            % Channel One search parameters
            refFiles = ls([obj.Experiment.homeDirectory, 'Ref']);
            refFiles = deblank(string(refFiles));
            refStr = ['ref_', int2fixedwidthstr(epochID, 4)];
            % Channel Two search parameters
            visFiles = ls([obj.Experiment.homeDirectory, 'Vis']);
            visFiles = deblank(string(visFiles));
            visStr = ['vis_', int2fixedwidthstr(epochID, 4)];

            ep.addFile('RefVideo', ['Ref', filesep,...
                obj.Experiment.getFileHeader(), '_', refStr, '.avi']);
            ep.addFile('VisVideo', ['Vis', filesep,...
                obj.Experiment.getFileHeader(), '_', visStr, '.avi']);

            % Processed video for analysis
            ep.addFile('AnalysisVideo', string(['Analysis', filesep, 'Videos', filesep, visStr, '.tif']));

            % Find csv output file
            csvFiles = multicontains(refFiles, {refStr, 'csv'});
            match = csvFiles(~contains(csvFiles, 'motion'));
            if ~isempty(match)
                match = obj.checkFilesFound(match);
                ep.addFile('FrameReport', "Ref" + filesep + match);
            else
                warning('Frame report for epoch %u not found', epochID);
            end

            % Find registration report
            regFiles = multicontains(refFiles, {'motion', 'csv'});
            match = find(contains(regFiles, refStr));
            if ~isempty(match)
                % Return warning if > 1 registration files found
                if numel(match) > 1
                    warning('%u registrations found for epoch %u, using first\n', ...
                        numel(match), epochID);
                end
                match = obj.checkFilesFound(match);
                ep.addFile('RegistrationReport', "Ref" + filesep + regFiles(match));
            else
                warning('Registration report for epoch %u not found', epochID);
            end

            % Find registration parameters
            regFiles = multicontains(refFiles, {'params', 'txt'});
            ind = find(contains(regFiles, refStr));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('RegistrationParameters', "Ref" + filesep + regFiles(ind));
            else
                warning('Registration parameters for epoch %u not found', epochID);
            end

            % Find stimulus reference images
            if ep.epochType.isPhysiology
                match = find(contains(refFiles, [refStr, '_linear']));
                if ~isempty(match)
                    match = obj.checkFilesFound(match);
                    ep.addFile('ReferenceImage', "Ref" + filesep + match);
                else
                    warning('Reference image for epoch %u not found', epochID);
                end
            end

            % Find frame registered videos 
            match = multicontains(refFiles, {refStr, 'frame', '.avi'});
            if ~isempty(match)
                match = obj.checkFilesFound(match);
                ep.addFile('RefVideoFrameReg', "Ref" + filesep + match);
            else
                warning('Frame registered ref video for epoch %u not found', epochID);
            end

            match = multicontains(visFiles, {visStr, 'frame', '.avi'});
            if ~isempty(match)
                match = obj.checkFilesFound(match);
                ep.addFile('VisVideoFrameReg', "Vis" + filesep + match);
            else
                warning('Strip registered ref video for epoch %u not found', epochID);
            end

            % Find strip registered videos
            match = multicontains(refFiles, {refStr, 'strip', '.avi'});
            if ~isempty(match)
                match = obj.checkFilesFound(match);
                ep.addFile('RefVideoStripReg', "Ref" + filesep + match);
            else
                warning('Strip registered ref video for epoch %u not found', epochID);
            end

            match = multicontains(visFiles, {visStr, 'strip', '.avi'});
            if ~isempty(match)
                match = obj.checkFilesFound(match);
                ep.addFile('VisVideoStripReg', "Vis" + filesep + match);
            else
                warning('Strip registered ref video for epoch %u not found', epochID);
            end

            % Find LED stimulus files, if necessary
            if ep.epochType == sara.EpochTypes.Spectral
                match = multicontains(visFiles, {visStr, '.json'});
                if ~isempty(match)
                    match = obj.checkFilesFound(match);
                    ep.addFile('LedVoltages', "Vis" + filesep + match);
                else
                    warning('LED voltage json files for epoch %u not found', epochID);
                end
            end
        end

        function addStripRegistration(obj, ep) %#ok<INUSL> 
            % ADDSTRIPREGISTRATION
            %
            % Syntax:
            %   addStripRegistration(obj, epoch)
            % -------------------------------------------------------------
            reg = aod.builtin.registrations.StripRegistration(ep);
            reader = aod.builtin.readers.RegistrationParameterReader(...
                ep.getFilePath('RegistrationParameters'));
            reg.addParameter(reader.read());
            ep.addRegistration(reg);
        end
    end

    methods (Static)
        function matches = checkFilesFound(matches)
            % CHECKFILESFOUND
            %
            % Syntax:
            %   ind = obj.checkFilesFound(ind)
            % -------------------------------------------------------------
            if numel(matches) > 1
                matches = matches(1);
            end
        end
    end
end