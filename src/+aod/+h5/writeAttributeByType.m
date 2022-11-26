function writeAttributeByType(hdfName, hdfPath, name, value)
% WRITEATTRIBUTEBYTYPE
%
% Description:
%   Ensure datatype compatibility, then write as an attribute
%
% Syntax:
%   writeAttributeByType(hdfName, hdfPath, name, value)
% -------------------------------------------------------------------------

    arguments
        hdfName             {mustBeFile}
        hdfPath             char
        name                char
        value 
    end

    if isdatetime(value)
        value = datestr(value); %#ok<DATST> 
    end

    aod.h5.HDF5.writeatts(hdfName, hdfPath, name, value);
    fprintf('Wrote %s:%s attribute %s\n', hdfName, hdfPath, name);
    