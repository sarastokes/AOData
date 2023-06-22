function success = writeSpecificationManager(hdfName, pathName, dsetName, SM, parentClass)
% Write aod.specification.SpecificationManager as an HDF5 dataset
%
% Syntax:
%   success = aod.h5.writeSpecificationManager(hdfName, pathName, dsetName,...
%       SM, parentClass)
%
% Inputs:
%   hdfName         char or H5ML.id
%       HDF5 file name or identifier
%   pathName        char
%       HDF5 path to group where dataset will be written
%   dsetName        char
%       Name of the dataset
%   Sm              aod.specification.SpecificationManager
%       Specification manager to be written
% Optional inputs:
%   parentClass     string
%       Name of the parent class (default taken from SM's className)
%
% Outputs:
%   success         logical
%       Whether the SpecificationManager was written or not
%
% See also:
%   aod.specification.SpecificationManager, aod.h5.readSpecificationManager

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        hdfName
        pathName
        dsetName
        SM              {mustBeA(SM, 'aod.specification.SpecificationManager')}
        parentClass     string = ""
    end
    
    if isempty(SM)
        warning('writeSpecificationManager:Empty',...
            'Empty SpecificationManager not written to %s', fullpath);
        success = false;
        return
    end

    if parentClass == ""
        parentClass = SM.className;
    end
    
    T = SM.table();
    h5tools.write(hdfName, pathName, dsetName, T);
    h5tools.writeatt(hdfName, h5tools.util.buildPath(pathName, dsetName),...
        'Class', class(SM),...
        'ParentClass', parentClass,...
        'SpecificationType', SM.specType,...
        'DateWritten', datetime('now'));
    success = true;

    