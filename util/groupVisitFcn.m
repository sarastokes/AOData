function [status, groupNames] = groupVisitFcn(rootID, name, groupNames)
    % GROUPVISITFCN
    %
    % Syntax:
    %   [status, groupNames] = groupVisitFcn(rootID, name, groupNames)
    %
    % Inputs:
    %   groupNames           string
    %
    % Use:
    %   [~, groupNames] = H5O.visit(fileID, 'H5_INDEX_NAME',... 
    %       'H5_ITER_NATIVE', @groupVisitFcn, groupNames);
    %
    % Notes:
    %   Having trouble getting H5O.visit to use this function while it's in
    %   a package. Saving here for now.
    %
    % History:
    %   16Oct2022 - SSP
    % ---------------------------------------------------------------------

    objID = H5O.open(rootID, name, 'H5P_DEFAULT');
    info = H5O.get_info(objID);
    H5O.close(objID);
    
    if string(name) == "."
        status = 0;
        return
    end

    if info.type == H5ML.get_constant_value('H5O_TYPE_GROUP');
        groupNames = cat(1, groupNames, "/" + string(name));
    end

    status = 0;