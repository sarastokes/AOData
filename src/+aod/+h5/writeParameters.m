function writeParameters(hdfName, groupPath, params)
% WRITEPARAMETERS
%
% Description:
%   Write an aod.util.Parameters as attributes to a group
%
% Syntax:
%   writeParameters(hdfName, groupPath, params)
%
% Inputs:
%   hdfName         char
%       Name of the HDF5 file
%   groupPath       char
%       Name of the HDF group where attributes will be written
%   params          aod.util.Parameters
%       Key/value pairs to write as attributes
%
% -------------------------------------------------------------------------
    arguments 
        hdfName             {mustBeFile(hdfName)}
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
        h5tools.writeatt(hdfName, groupPath, keys{i}, iValue);
    end