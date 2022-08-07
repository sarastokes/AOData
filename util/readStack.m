function imStack = readStack(videoName)
    % READSTACK
    %
    % Syntax:
    %   imStack = readStack(videoName)
    % -------------------------------------------------------------
    [~, ~, extension] = fileparts(videoName);
    switch extension
        case {'.tif', '.tiff'}
            reader = aod.core.readers.TiffReader(videoName);
        case '.avi'
            reader = aod.core.readers.AviReader(videoName);
        otherwise
            error('Unrecognized file extension!');
    end
    imStack = reader.read();
    fprintf('Loaded %s\n', videoName);