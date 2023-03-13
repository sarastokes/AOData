classdef EpochFileManager < aod.util.FileManager
% Identify epoch files
%
% Parent:
%   aod.util.FileManager
%
% Constructor:
%   obj = sara.util.EpochFileManager(experimentFolder)
%
% Methods:
%   ep = populateFileNames(obj, ep)
%
% Support methods:
%   ep = populateChannelOne(obj, ep, chanFolderName)
%   ep = populateChannelTwo(obj, ep, chanFolderName)
%   ep = populateAnalysisFiles(obj, ep)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    methods
        function obj = EpochFileManager(baseFolderPath)
            obj = obj@aod.util.FileManager(baseFolderPath);
        end

        function ep = populateFileNames(obj, ep)
            ep = obj.populateChannelOne(ep);
            ep = obj.populateChannelTwo(ep);
            ep = obj.populateAnalysisFiles(ep);

            % Display the files identified
            fprintf('Epoch %u - %u files found\n',... 
                ep.ID, numel(ep.files.keys));
        end
    end

    methods
        function ep = populateChannelOne(obj, ep, chanFolder)
            if nargin < 3
                chanFolder = 'Ref';
            end 

            % Collect all the files from the channel folder
            files = obj.collectFiles(chanFolder);

            % Assumptions:
            % - Video IDs are 4 digits long (e.g. 0004 for #4)
            % - There are no numbers directly adjacent to those 4 digits
            %       So those 4 numbers can occur within other numbers too
            pat = digitBoundary + int2fixedwidthstr(ep.ID, 4) + digitBoundary;

            % Get just the files for the epoch ID
            epochFiles = extractMatches(files, pat);
            if isempty(epochFiles)
                error("EpochFileManager:NoFilesFound",...
                    "No files found in %s for ID %u", ...
                    fullfile(obj.baseFolderPath, chanFolder), ID);
            end
            % Add back in the channel folder name
            for i = 1:numel(epochFiles)
                epochFiles(i) = fullfile(chanFolder, epochFiles(i));
            end

            % Assumption:
            % - Recorded videos are avi files
            aviFiles = epochFiles(contains(epochFiles, '.avi'));

            % Assumption
            % - The shortest .avi file is the original one
            [~, idx] = min(arrayfun(@strlength, aviFiles));
            ep.setFile('RefVideo', aviFiles(idx));

            % Assumption:
            %   strip and frame registered videos contain 'strip' 'frame'
            idx = find(contains(aviFiles, '_strip_'));
            if ~isempty(idx)
                idx = obj.checkFilesFound(idx);
                ep.setFile('RefVideoFrameReg', aviFiles(idx));
            end

            idx = find(contains(aviFiles, '_frame_'));
            if ~isempty(idx)
                idx = obj.checkFilesFound(idx);
                ep.setFile('RefVideoStripReg', aviFiles(idx));
            end

            % Assumption:
            % - There is only one .dat file per registration
            idx = find(contains(epochFiles, '.dat'));
            if ~isempty(idx)
                idx = obj.checkFilesFound(idx);
                ep.setFile('RegDat', epochFiles(idx));
            end

            % Assumption:
            % - There are 0 or 2 reference images which are bmp
            % - The bmp files starting with reference aren't epoch-specific
            bmpFiles = epochFiles(contains(epochFiles, '.bmp') &...
                ~contains(epochFiles, 'reference'));
            if ~isempty(bmpFiles)
                idx = contains(bmpFiles, '_linear');
                ep.setFile('RefImageLinear', bmpFiles(idx));

                idx = contains(bmpFiles, '_linear');
                ep.setFile('RefImage', bmpFiles(~idx));
            end

            % Assumption:
            % - Frame and strip registration both save a .tif file
            tifFiles = epochFiles(contains(epochFiles, '.tif'));
            if ~isempty(tifFiles)    
                idx = find(contains(tifFiles, 'strip'));
                if ~isempty(idx)
                    idx = obj.checkFilesFound(idx);
                    ep.setFile('StripRegImage', tifFiles(idx));
                end

                idx = find(contains(tifFiles, 'frame'));
                if ~isempty(idx)
                    idx = obj.checkFilesFound(idx);
                    ep.setFile('FrameRegImage', tifFiles(idx));
                end
            end

            % Assumptions:
            % - The shortest .csv file was created during experiment
            % - The one containing "motion" came from registration
            csvFiles = epochFiles(contains(epochFiles, '.csv'));
            if ~isempty(csvFiles)
                [~, idx] = min(arrayfun(@strlength, csvFiles));
                ep.setFile('FrameTable', csvFiles(idx));

                idx = find(contains(csvFiles, 'motion'));
                if ~isempty(idx)
                    idx = obj.checkFilesFound(idx);
                    ep.setFile('RegMotion', csvFiles(idx));
                end
            end

            % Assumptions:
            % - The .txt file containing params was from registration
            % - The additional .txt file that does not contain params is
            %   the imaging parameter output
            txtFiles = epochFiles(contains(epochFiles, '.txt'));
            if ~isempty(txtFiles)
                idx = find(~contains(txtFiles, 'params'));
                if ~isempty(idx)
                    ep.setFile('ImagingParams', txtFiles(idx));
                end

                idx = find(contains(txtFiles, 'params'));
                if ~isempty(idx)
                    idx = obj.checkFilesFound(idx);
                    ep.setFile('RegParams', txtFiles(idx));
                end
            end
        end

        function ep = populateChannelTwo(obj, ep, chanFolder)
            if nargin < 3
                chanFolder = 'Vis';
            end

            % Collect all the files from the channel folder
            files = obj.collectFiles(chanFolder);

            
            % Assumptions:
            % - Video IDs are 4 digits long (e.g. 0004 for #4)
            % - There are no numbers directly adjacent to those 4 digits
            %       So those 4 numbers can occur within other numbers too
            pat = digitBoundary + int2fixedwidthstr(ep.ID, 4) + digitBoundary;

            % Get just the files for the epoch ID
            epochFiles = extractMatches(files, pat);
            if isempty(epochFiles)
                error("EpochFileManager:NoFilesFound",...
                    "No files found in %s for ID %u", ...
                    fullfile(obj.baseFolderPath, chanFolder), ID);
            end
            % Add back in the channel folder name
            for i = 1:numel(epochFiles)
                epochFiles(i) = fullfile(chanFolder, epochFiles(i));
            end

            % Assumption:
            % - Recorded videos are avi files
            aviFiles = epochFiles(contains(epochFiles, '.avi'));

            % Assumption
            % - The shortest .avi file is the original one
            [~, idx] = min(arrayfun(@strlength, aviFiles));
            ep.setFile('VisVideo', aviFiles(idx));

            % Assumption:
            %  - strip and frame registered videos contain 'strip' 'frame'
            idx = find(contains(aviFiles, '_strip_'));
            if ~isempty(idx)
                idx = obj.checkFilesFound(idx);
                ep.setFile('VisVideoFrameReg', aviFiles(idx));
            end

            idx = find(contains(aviFiles, '_frame_'));
            if ~isempty(idx)
                idx = obj.checkFilesFound(idx);
                ep.setFile('VisVideoStripReg', aviFiles(idx));
            end

            % Assumption:
            % - LED voltages are the only json file output
            idx = find(contains(epochFiles, '.json'));
            if ~isempty(idx)
                ep.setFile('LedVoltages', epochFiles(idx));
            end
        end
        
        function ep = populateAnalysisFiles(~, ep)
            % Files specific to my analysis pipeline
            ep.setFile('AnalysisVideo', fullfile('Analysis', 'Snapshots',...
                sprintf('vis_%s.tif', int2fixedwidthstr(ep.ID, 4))));
        end
    end
end