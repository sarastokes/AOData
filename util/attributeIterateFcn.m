function [status, names] = attributeIterateFcn(~, name, ~, names)
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
    