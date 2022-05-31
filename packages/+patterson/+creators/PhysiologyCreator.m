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
            obj.Dataset.addSource(source);
            obj.Dataset.initParameters(varargin{:});
        end

        function addEpochs(obj, epochIDs)
            fprintf('Adding epochs... ');
            for i = 1:numel(epochIDs)
                %try
                    obj.makeEpoch(epochIDs(i));
                % catch
                %    warning('Unable to add epoch %u, skipping', epochIDs(i));
                %end
                fprintf('%u ', epochIDs(i));
            end
            fprintf('\nDone.\n')
        end
    
        function addRegions(obj, regions)
            obj.Dataset.addRegions(regions);
        end
    end

    methods (Access = private)
        function makeEpoch(obj, epochID)
            ep = patterson.core.Epoch(epochID, obj.Dataset);
            obj.extractEpochAttributes(ep);
            obj.populateFileNames(ep);
            if ~isempty(ep.getFilePath('RegistrationReport'))
                reg = aod.builtin.registrations.StripRegistration(ep);
                ep.addRegistration(reg);
            end
            obj.Dataset.addEpoch(ep);
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
            epochID = ep.ID;
            fName = obj.getAttributeFile(epochID);

            txt = readProperty(fName, 'Date/Time = ');
            txt = erase(txt, ' (yyyy-mm-dd:hh:mm:ss)');
            ep.startTime(datetime(txt, 'InputFormat', 'yyyy-MM-dd HH:mm:ss'));

            ep.addFile('TrialFile', readProperty(fName, 'Trial file name = '));
            txt = strsplit(ep.files('TrialFile'), filesep);
            ep.addParameter('StimulusName', txt{end});

            ep.addParameter('RefPMT',...
                str2double(readProperty(fName, 'Reflectance PMT gain  = ')));
            ep.addParameter('VisPMT',...
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
                obj.Dataset.getEpochHeader(), '_', refStr, '.avi']);
            ep.addFile('VisVideo', ['Vis', filesep,...
                obj.Dataset.getEpochHeader(), '_', visStr, '.avi']);

            % Processed video for analysis
            ep.addFile('AnalysisVideo', string(['Analysis', filesep, visStr, '.tif']));

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
                ep.addFile('RegistrationReport', ["Ref" + filesep + regFiles(ind)]);
                % aod.builtin.readers.RegistrationReportReader(refFiles(ind));
            else
                warning('Registration report for epoch %u not found', epochID);
            end

            % Find registration parameters
            regFiles = refFiles(multicontains(refFiles, {'params', 'txt'}));
            ind = find(contains(regFiles, [refStr, '_']));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('RegistrationParameters', ["Ref" + filesep + regFiles(ind)]);
            else
                warning('Registration parameters for epoch %u not found', epochID);
            end

            % Find stimulus reference images
            ind = find(contains(refFiles, [refStr, '_linear']));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('ReferenceImage', ["Ref" + filesep + refFiles(ind)]);
            else
                warning('Registration parameters for epoch %u not found', epochID);
            end

            % Find frame registered videos 
            ind = find(multicontains(refFiles, {refStr, 'frame', '.avi'}));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('RefVideoFrameReg', ["Ref" + filesep + refFiles(ind)]);
            else
                warning('Frame registered ref video for epoch %u not found', epochID);
            end

            ind = find(multicontains(visFiles, {visStr, 'frame', '.avi'}));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('VisVideoFrameReg', ["Vis" + filesep + visFiles(ind)]);
            else
                warning('Strip registered ref video for epoch %u not found', epochID);
            end

            % Find strip registered videos
            ind = find(multicontains(refFiles, {refStr, 'strip', '.avi'}));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('RefVideoStripReg', ["Ref" + filesep + refFiles(ind)]);
            else
                warning('Strip registered ref video for epoch %u not found', epochID);
            end

            ind = find(multicontains(visFiles, {visStr, 'strip', '.avi'}));
            if ~isempty(ind)
                ind = obj.checkFilesFound(ind);
                ep.addFile('VisVideoStripReg', ["Vis" + filesep + visFiles(ind)]);
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