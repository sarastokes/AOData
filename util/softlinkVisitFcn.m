function [status, dataOut] = softlinkVisitFcn(groupID, name, dataIn)
    % LINKVISITFCN
    %
    % Description:
    %   Iterator function for visiting all links in an HDF5 file and 
    %   returning the names of soft links
    %
    % Syntax:
    %   [status, dataOut] = softlinkVisitFcn(groupID, name, dataIn)
    %
    % Notes:
    %   Having trouble getting H5L.visit to use this function while it's in
    %   a package. Saving here for now.
    %
    % See also:
    %   collectAllSoftlinks
    %
    % History:
    %   21Nov2022 - SSP
    % ---------------------------------------------------------------------

    info = H5L.get_info(groupID, name, 'H5P_DEFAULT');

    if isequal(info.type, H5ML.get_constant_value('H5L_TYPE_SOFT'))
        dataOut = cat(1, dataIn, "/" + string(name));
    else
        dataOut = dataIn;
    end

    status = 0;