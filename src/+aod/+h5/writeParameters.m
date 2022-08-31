function writeParameters(hdfName, groupPath, params)

    arguments 
        hdfName             {mustBeFile}
        groupPath           char 
        params              {mustBeA(params, 'aod.util.Parameters')}
    end
    
    keys = params.keys;
    values = params.values;

    for i = 1:numel(keys)
        iValue = values{i};
        if isdatetime(iValue)
            iValue = datestr(iValue);
        end
        aod.h5.HDF5.writeatts(hdfName, groupPath, keys{i}, iValue);
    end