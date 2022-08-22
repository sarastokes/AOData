function success = writeDatasetByType(fileName, pathName, dsetName, data)

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
        try
            HDF5.makeCompoundDataset(fileName, pathName, dsetName, data);
            HDF5.writeatts(fileName, fullPath, 'Class', class(data));
        catch
            % Delete dataset created while attempting compound type
            if aod.h5.HDF5.exists(fileName, fullPath)
                HDF5.deleteObject(fileName, fullPath);
            end
            HDF5.makeStructDataset(fileName, pathName, dsetName, data);
            HDF5.writeatts(fileName, fullPath, 'Class', class(data));
        end
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
        case 'affine2d'
            HDF5.makeMatrixDataset(fileName, pathName, dsetName, data.T);
            HDF5.writeatts(fileName, fullPath, 'Class', class(data));
        otherwise
            success = false;
            % error("aod.h6.writeDataByType:UnrecognizedClass",...
            %     "Data class %s was not recognized", class(data));
    end
