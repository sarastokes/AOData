classdef LedFrameTableReader < aod.core.FileReader
% LEDFRAMETABLEREADER
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        frameRate           % Hz
    end

    methods
        function obj = LedFrameTableReader(fName)
            obj = obj@aod.core.FileReader(fName);
        end

        function out = read(obj)  
            
            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
            T = readtable(obj.fullFile);
            T.Properties.VariableNames = {'Frame', 'TimeInterval', 'TimeStamp', 'R', 'G', 'B'};
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

            % Add column for epoch-specific timing
            x = T.TimeStamp - T.TimeStamp(1) + T.TimeInterval(1);
            T.Timing = x / 1000;
            
            % The final frames in the stimulus log weren't actually saved
            % Use the video size to determine which frames are relevant
            try
                fName = char(obj.fullFile);
                videoPath = fileparts(fileparts(fName));
                videoPath = fullfile(videoPath, 'Analysis');

                videoPath = fullfile(videoPath, fName(end-11:end-4));
                imStack = readTiffStack(videoPath);
                numFrames = size(imStack, 3) + 1;
            catch
                try
                    videoPath = strrep(obj.fullFile, '.csv', '.avi');
                    v = VideoReader(videoPath);
                catch
                    videoPath = strrep(obj.fullFile, '.csv', 'O.avi');
                    v = VideoReader(videoPath);
                end
                numFrames = v.NumFrames;
            end
        
            % Remove extra frames and also the blank frames
            T = T(2:numFrames, :);

            TT = timetable(seconds(T.Timing), T.TimeInterval, T.TimeStamp, T.R, T.G, T.B,...
                'VariableNames', {'TimeInterval', 'TimeStamp', 'R', 'G', 'B'});
            obj.Data = TT;
            out = TT;

            obj.frameRate = 1000/mean(T.TimeInterval);
        end
    end
end