function writeAttributeByType(hdfName, hdfPath, attName, data)
    % WRITEATTRIBUTEBYTYPE
    %
    % Description:
    %   Ensure datatype compatibility, then write as an attribute 
    %
    % Syntax:
    %   writeAttributeByType(hdfName, hdfPath, varargin)
    %
    % Inputs:
    %   hdfName     char
    %       HDF5 file name
    %   hdfPath     char
    %       Path of the dataset/group where attributes will be written
    %   attName     char
    %       Attribute name
    %   data        
    %       Attribute data
    % -------------------------------------------------------------------------

    arguments
        hdfName     {mustBeFile(hdfName)}
        hdfPath     char
        attName     char
        data        
    end

    if islogical(data)
        data = int32(data);
    elseif isdatetime(data)
        data = datestr(data);
    elseif isenum(data)
        data = [class(data), '.', char(data)];
    elseif ismember(class(data), {'table', 'struct', 'containers.Map', 'timetable'})
        error('writeAttributeByType',...
            'Structs, tables and maps cannot be written as attributes');
    end

    h5writeatt(hdfName, hdfPath, attName, data);
end