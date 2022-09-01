function out = readDatasetByType(hdfName, groupPath, dsetName, className)

    import aod.h5.HDF5

    fullPath = HDF5.buildPath(groupPath, dsetName);
    disp(fullPath)

    if nargin < 4
        className = h5readatt(hdfName, fullPath, 'Class');
    end

    if ismember(className, {'containers.Map', 'aod.util.Parameters'})
        if strcmp(className, 'containers.Map')
            out = containers.Map();
        else
            out = aod.util.Parameters();
        end
        info = h5info(hdfName, fullPath);
        if isempty(info.Attributes)
            return
        end
        for i = 1:numel(info.Attributes)
            out(info.Attributes(i).Name) = info.Attributes(i).Value;
        end
        return
    else
        data = h5read(hdfName, fullPath);
    end


    switch className 
        case 'datetime'
            out = datetime(data, 'Format',... 
                h5readatt(hdfName, fullPath, 'Format'));
        case {'table', 'timetable'}
            out = struct2table(data);
            colClasses = h5readatt(hdfName, fullPath, 'ColumnClass');
            % TODO: This seems too hard, am I missing something here
            colClasses = strsplit(colClasses, ', '); 
            for i = 1:numel(colClasses)
                if strcmp(colClasses{i}, 'string')                        
                    colName = out.Properties.VariableNames{i};
                    out.(colName) = string(out.(colName));
                end
            end
            if strcmp(className, 'timetable')
                out.Time = seconds(out.Time);
                out = table2timetable(out);
            end
        case 'string'
            out = string(data);
        case 'logical'
            out = logical(data);
        case 'duration'
            out = seconds(data);
        case 'enum'
            enumClass = h5readatt(hdfName, fullPath, 'EnumClass');
            eval(sprintf('out = %s.%s', enumClass, data));
        case 'affine2d'
            out = affine2d(data);
        otherwise
            out = data;
    end