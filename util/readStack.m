function imStack = readStack(videoName)
% READSTACK
%
% Syntax:
%   imStack = readStack(videoName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    [~, ~, extension] = fileparts(videoName);
    switch extension
        case {'.tif', '.tiff'}
            reader = aod.util.readers.TiffReader(videoName);
        case '.avi'
            reader = aod.util.readers.AviReader(videoName);
        otherwise
            error('Unrecognized file extension!');
    end
    imStack = reader.readFile();
    fprintf('Loaded %s\n', videoName);