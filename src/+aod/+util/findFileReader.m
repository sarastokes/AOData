function out = findFileReader(fileName)


% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    [~, ~, ext] = fileparts(fileName);

    switch ext 
        case '.avi'
            out = aod.util.AviReader(fileName);
        case {'.tif', '.tiff'}
            out = aod.util.TiffReader(fileName);
        case '.json'
            out = aod.util.JsonReader(fileName);
        case '.mat'
            out = aod.util.readers.MatReader(fileName);
        case {'.png', '.bmp', '.jpeg'}
            out = aod.util.readers.ImageReader(fileName);
        otherwise
            error('findFileReader:UnknownExtension',...
                'No default FileReader found for %s', ext);
    end