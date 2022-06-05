classdef PhysiologyCreator < aod.core.Creator

    properties (SetAccess = private)
        Dataset
    end

    methods
        function obj = PhysiologyCreator(homeDirectory)
            obj@aod.core.Creator(homeDirectory);
        end

        function createDataset(obj, expDate, source, location, varargin)
            obj.Dataset = patterson.datasets.Physiology(obj.homeDirectory, expDate, location);
            obj.Dataset.setSource(source);
            obj.Dataset.initParameters(varargin{:});
        end

        function addEpochs(obj, epochIDs, epochType)
            % ADDEPOCHS
            %
            % Syntax:
            %   obj.addEpochs(epochIDs, epochType)
            % -------------------------------------------------------------
            if nargin < 3
                epochType = patterson.EpochTypes.Unknown;
            end

            fprintf('Adding epochs... ');
            for i = 1:numel(epochIDs)
                ep = obj.makeEpoch(epochIDs(i), epochType);          
                obj.Dataset.addEpoch(ep);
                fprintf('%u ', epochIDs(i));
            end
            obj.Dataset.sortEpochs();
            fprintf('\nDone.\n')
        end

        function addCalibration(obj, calibration)
            % ADDLEDCALIBRATION
            %
            % Syntax:
            %   obj.addCalibration(calibration)
            % -------------------------------------------------------------
            obj.Dataset.addCalibration(calibration);
        end
    
        function addRegions(obj, regions)
            % ADDREGIONS
            %
            % Syntax:
            %   obj.addRegions(regions)
            % -------------------------------------------------------------
            obj.Dataset.addRegions(regions);
        end

        function addTransforms(obj, fName, epochIDs, varargin)
            % ADDTRANSFORMS
            %
            % Syntax:
            %   obj.addTransforms(fName, epochIDs, varargin)
            % -------------------------------------------------------------
            if ~isfile(fName)
                fName = [obj.Dataset.getAnalysisFolder(), filesep, fName];
            end
            reader = aod.builtin.readers.RigidTransformReader(fName);
            tforms = reader.read();

            for i = 1:numel(epochIDs)
                ep = obj.Dataset.id2epoch(epochIDs(i));
                reg = aod.builtin.registrations.SiftRegistration(...
                    ep, squeeze(tforms(:,:,i)), varargin{:});
                ep.addRegistration(reg);
                ep.addFile('SiftTransform', erase(fName, obj.homeDirectory));
            end
        end
    end

    methods (Access = protected)
        function ep = makeEpoch(obj, epochID, epochType)
            % MAKEEPOCH
            ep = patterson.Epoch(epochID, obj.Dataset, epochType);
            if epochType.isPhysiology
                obj.extractEpochAttributes(ep);
            end
            obj.populateFileNames(ep);
            if ~isempty(ep.getFilePath('RegistrationReport'))
                reg = aod.builtin.registrations.StripRegistration(ep);
                reader = aod.builtin.readers.RegistrationParameterReader(ep.getFilePath('RegistrationParameters'));
                reg.addParameter(reader.read());
                ep.addRegistration(reg);
            end
            if epochType == patterson.EpochTypes.Spatial
                protocol = patterson.factories.SpatialProtocolFactory(...
                    ep.getFilePath('TrialFile'), obj.Dataset.getCalibration('patterson.calibrations.TopticaCalibration'));
                stimulus = aod.builtin.stimuli.SpatialStimulus(ep, protocol);
                ep.addStimulus(stimulus);
            end
        end
    end

    methods %(Access = protected)
        function fName = getAttributeFile(obj, epochID)
            fName = sprintf('%u_%s_ref_%s.txt',...
                obj.Dataset.Source.ID, obj.Dataset.experimentDate,...
                int2fixedwidthstr(epochID, 4));
            fName = [obj.Dataset.homeDirectory, filesep, 'Ref', filesep, fName];
        end

        function extractEpochAttributes(obj, ep)
            % TODO: make this a FileReader class
            epochID = ep.ID;
            fName = obj.getAttributeFile(epochID);

            txt = readProperty(fName, 'Date/Time = ');
            txt = erase(txt, ' (yyyy-mm-dd:hh:mm:ss)');
            ep.startTime = datetime(txt, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');

            % Additional file names
            ep.addFile('TrialFile', readProperty(fName, 'Trial file name = '));
            txt = strsplit(ep.files('TrialFile'), filesep);
            ep.addParameter('StimulusName', txt{end});

            ep.addFile('StimVideoName',...
                readProperty(fName, 'Stimulus video = '));
            ep.addFile('BackgroundVideoName',...
                readProperty(fName, 'Background video = '));

            txt = readProperty(fName, 'Stimulus location in linear stabilized space = ');
            txt = erase(txt, '('); txt = erase(txt, ')');
            txt = strsplit(txt, ', ');
            ep.addParameter('StimulusLocation', [str2double(txt{1}), str2double(txt{2})]);

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

            % Power modulation 
            ep.addParameter('PowerModulation',... 
                convertYesNo(readProperty(fName, 'Stimulus power modulation = ')));

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
            stim = patterson.stimuli.Mustang(ep, mustangValue);
            ep.addStimulus(stim);
        end

        function populateFileNames(obj, ep)
            epochID = ep.ID;
            % Ref channel search parameters
            refFiles = ls([obj.Dataset.homeDirectory, 'Ref']);
            refFiles = string(deblank(refFiles));
            refStr = ['ref_', int2fixedwidthstr(epochID, 4)];
            % Vis channel search parameters
            visFiles = ls([obj.Dataset.homeDirectory, 'Vis']);
            visFiles = string(deblank(visFiles));
            visStr = ['vis_', int2fixedwidthstr(epochID, 4)];

            ep.addFile('RefVideo', ['Ref', filesep,...
                obj.Dataset.getFileHeader(), '_', refStr, '.avi']);
            ep.addFile('VisVideo', ['Vis', filesep,...
                obj.Dataset.getFileHeader(), '_', visStr, '.avi']);

            % Processed video for analysis
            ep.addFile('AnalysisVideo', string(['Analysis', filesep, 'Videos', filesep, visStr, '.tif']));

            % Find registration report
            regFiles = refFiles(multicontains(refFiles, {'motion', 'csv'}));
            ind = find(contains(regFiles, refStr));
            if ~isempty(ind)
                % Return warning if > 1 registration files found
                if numel(ind) > 1
                    warning('%u registrations found for epoch %u, using first\n', ...
                        numel(ind), epochID);
                end
                ind = obj.checkFilesFound(ind);
                ep.addFile('RegistrationReport', "Ref" + filesep + regFiles(ind));
            else
                warning('Registration report for epoch %u not found', epochID);
            end

            % Find registration parameters
            regFiles = refFiles(multicontains(refFiles, {'params', 'txt'}));
            ind = find(contains(regFiles, [refStr, '_']));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('RegistrationParameters', "Ref" + filesep + regFiles(ind));
            else
                warning('Registration parameters for epoch %u not found', epochID);
            end

            % Find stimulus reference images
            if ep.epochType.isPhysiology
                ind = find(contains(refFiles, [refStr, '_linear']));
                if ~isempty(ind)
                    ind = obj.checkFilesFound(ind);
                    ep.addFile('ReferenceImage', "Ref" + filesep + refFiles(ind));
                else
                    warning('Reference image for epoch %u not found', epochID);
                end
            end

            % Find frame registered videos 
            ind = find(multicontains(refFiles, {refStr, 'frame', '.avi'}));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('RefVideoFrameReg', "Ref" + filesep + refFiles(ind));
            else
                warning('Frame registered ref video for epoch %u not found', epochID);
            end

            ind = find(multicontains(visFiles, {visStr, 'frame', '.avi'}));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('VisVideoFrameReg', "Vis" + filesep + visFiles(ind));
            else
                warning('Strip registered ref video for epoch %u not found', epochID);
            end

            % Find strip registered videos
            ind = find(multicontains(refFiles, {refStr, 'strip', '.avi'}));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('RefVideoStripReg', "Ref" + filesep + refFiles(ind));
            else
                warning('Strip registered ref video for epoch %u not found', epochID);
            end

            ind = find(multicontains(visFiles, {visStr, 'strip', '.avi'}));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('VisVideoStripReg', "Vis" + filesep + visFiles(ind));
            else
                warning('Strip registered ref video for epoch %u not found', epochID);
            end
        end
    end

    methods (Static)
        function ind = checkFilesFound(ind)
            % CHECKFILESFOUND
            %
            % Syntax:
            %   ind = obj.checkFilesFound(ind)
            % -------------------------------------------------------------
            if numel(ind) > 1
                ind = ind(1);
            end
        end
    end
end