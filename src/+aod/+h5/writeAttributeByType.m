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
        value = datestr(value);
    end

    aod.h5.HDF5.writeatts(hdfName, hdfPath, name, value);
    