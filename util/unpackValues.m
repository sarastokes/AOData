function out = unpackValues(map)
% Unpack the values from a containers.Map
%
% Syntax:
%   out = unpackValues(map)
%
% Inputs:
%   map         containers.Map or aod.common.KeyValueMap
%
% Outputs:
%   Array of values (must be of same data type)
% -------------------------------------------------------------------------

    out = vertcat(map.values);
    out = vertcat(out{:});
