function out = readDatasetByType(hdfName, groupPath, D)

    import aod.h5.HDF5

    fullPath = HDF5.buildPath(groupPath, D.name);
    data = h5read(hdfFile, fullPath);

    numAtts = numel(D.Attributes);
    className = h5readatt(hdfName, fullPath, 'Class');

    switch className 
        case 'datetime'
            out = datetime(data, 'Format',... 
                h5readatt(hdfName, fullPath, 'Format'));
        case 'table'
            out = struct2table(data);
        case 'scalarstring'
            out = string(data);
        case 'logical'
        case 'timetable'
            out = struct2table(data);
            out.Time = seconds(out.Time);
            out = table2timetable(out);
        case 'duration'
            out = seconds(data);
        case 'enum'
            eval(sprintf('out = %s', data));
        case 'affine2d'
            out = affine2d(data);
        otherwise
            out = data;
    end