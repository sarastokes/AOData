function names = getAttributeNames(hdfName, pathName)
    % GETALLATTRIBUTENAMES
    %
    % Description:
    %   Return all attribute names (faster than getAttributeNames)
    %
    % Syntax:
    %   names = getAllAttributeNames(hdfName, pathName)
    % -------------------------------------------------------------
    arguments
        hdfName            {mustBeFile(hdfName)} 
        pathName            char
    end

    fileID = H5F.open(hdfName);
    fileIDx = onCleanup(@()H5F.close(fileID));
    groupID = H5G.open(fileID, pathName);
    groupIDx = onCleanup(@()H5G.close(groupID));

    names = string.empty();
    [~, ~, names] = H5A.iterate(groupID, 'H5_INDEX_NAME',...
        'H5_ITER_NATIVE', 0, @attributeIterateFcn2, names);
end

function [status, names] = attributeIterateFcn2(~, name, ~, names)
    % ATTRIBUTEITERATEFCN
    %
    % Description:
    %   Best way I have found so far for efficiently returning all
    %   attribute names of an object
    %
    % Syntax:
    %   [status, names] = attributeIterateFcn(groupID, name, info, names)
    %
    % Inputs:
    %   names           string array
    %
    % Notes:
    %   Having trouble getting H5A.iterate to use this function while it's
    %   in a package or static method of a class. Saving here for now.
    %
    % History:
    %   17Oct2022 - SSP
    % ---------------------------------------------------------------------
    
    names = cat(1, names, string(name));
    status = 0;
end