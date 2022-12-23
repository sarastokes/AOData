function UUID = generateUUID()
% GENERATEUUID
%
% Description:
%   Returns a 36 character UUID string using Java's UUID function
%
% Syntax:
%   UUID = generateUUID()
%
% References:
%   Adapted from Luca Della Santina's Follicle Finder

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    jUUID = java.util.UUID.randomUUID;
    jUUID = jUUID.toString;
    UUID = string(jUUID.toCharArray');
