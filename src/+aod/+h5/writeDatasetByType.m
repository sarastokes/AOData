function success = writeDatasetByType(fileName, pathName, dsetName, data)
% Writes MATLAB dataset with attributes signaling the MATLAB datatype 
%
% Syntax:
%   success = writeDatasetByType(fileName, pathName, dsetName, data)
%
% Inputs:
%   fileName        char
%       The HDF5 file name
%   pathName        char
%       The HDF5 path for the group the dataset should be added to
%   dsetName        char
%       The name of the dataset
%   data            see supported data types
%       The data to write to the dataset
%
% Outputs:
%   success         logical
%       Whether or not the data was successfully written to HDF5
%
% Supported data types:
%   numeric, char, string, logical, table, timetable, datetime, duration
%   enum, struct, containers.Map(), affine2d, imref2d, simtform2d, cfit
% See README.md for limitations - essentially no multilevel data (e.g. 
%   structs/tables/containers.Maps that contain other tables, structs or 
%   containers.Maps
%
% See also:
%   readDatasetByType, readAttributeByType, writeAttributeByType
% -------------------------------------------------------------------------

    arguments
        fileName            char 
        pathName            char 
        dsetName            char 
        data
    end

    import aod.h5.HDF5

    fullPath = HDF5.buildPath(pathName, dsetName);
    success = true;

    if isnumeric(data)
        HDF5.makeMatrixDataset(fileName, pathName, dsetName, data);
        HDF5.writeatts(fileName, fullPath, 'Class', class(data));
        return
    end

    if ischar(data)    
        HDF5.makeTextDataset(fileName, pathName, dsetName, data);
        HDF5.writeatts(fileName, fullPath, 'Class', class(data));
        return
    end

    if isstring(data) 
        HDF5.makeStringDataset(fileName, pathName, dsetName, data);
        HDF5.writeatts(fileName, fullPath, 'Class', class(data));
        return
    end

    if isstruct(data) || istable(data)
        HDF5.makeCompoundDataset(fileName, pathName, dsetName, data);
        HDF5.writeatts(fileName, fullPath, 'Class', class(data));
        return
    end

    if isdatetime(data)
        HDF5.makeDateDataset(fileName, pathName, dsetName, data);
        return
    end

    if islogical(data)
        HDF5.makeMatrixDataset(fileName, pathName, dsetName, double(data));
        HDF5.writeatts(fileName, fullPath, 'Class', 'logical');
        return
    end

    if isenum(data)
        HDF5.makeEnumDataset(fileName, pathName, dsetName, data);
        return
    end

    if istimetable(data)
        T = timetable2table(data);
        T.Time = seconds(T.Time);
        HDF5.makeCompoundDataset(fileName, pathName, dsetName, T);
        HDF5.writeatts(fileName, fullPath, 'Class', class(data));
        return
    end

    if isduration(data)
        HDF5.makeMatrixDataset(fileName, pathName, dsetName, seconds(data));
        HDF5.writeatts(fileName, fullPath, 'Class', class(data),...
            'Units', 'seconds');
        return
    end

    % Misc datatypes
    switch class(data)
        case 'containers.Map'
            HDF5.makeMapDataset(fileName, pathName, dsetName, data); 
        case 'affine2d'
            HDF5.makeMatrixDataset(fileName, pathName, dsetName, data.T);
            HDF5.writeatts(fileName, fullPath, 'Class', class(data));
        case 'simtform2d'
            HDF5.makeTextDataset(fileName, pathName, dsetName, 'simtform2d');
            HDF5.writeatts(fileName, fullPath, 'Class', class(data),...
                'Dimensionality', data.Dimensionality,...
                'Scale', data.Scale,...
                'RotationAngle', data.RotationAngle,...
                'Translation', data.Translation);
        case 'imref2d'
            HDF5.makeTextDataset(fileName, pathName, dsetName, 'imref2d');
            HDF5.writeatts(fileName, fullPath, 'Class', class(data),...
                'XWorldLimits', data.XWorldLimits,...
                'YWorldLimits', data.YWorldLimits,...
                'ImageSize', data.ImageSize,...
                'PixelExtentInWorldX', data.PixelExtentInWorldX,...
                'PixelExtentInWorldY', data.PixelExtentInWorldY,...
                'ImageExtentInWorldX', data.ImageExtentInWorldX,...
                'ImageExtentInWorldY', data.ImageExtentInWorldY,...
                'YIntrinsicLimits', data.YIntrinsicLimits,...
                'XIntrinsicLimits', data.XIntrinsicLimits);
        case 'cfit'
            coeffNames = string(coeffnames(data));
            coeffValues = [];
            for i = 1:numel(coeffNames)
                coeffValues = cat(2, coeffValues, data.(coeffNames(i)));
            end
            HDF5.makeTextDataset(fileName, pathName, dsetName,...
                [fitType, ' ', fit]);
            HDF5.writeatts(fileName, fullPath, 'Class', class(data),...
                'FitType', fitType,...
                'Coefficients', coeffValues);
        otherwise
            warning('writeDatasetByType:UnidentifiedDataType',...
                'The datatype %s is not supported', class(data));
            success = false;
    end
