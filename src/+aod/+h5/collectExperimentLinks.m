function T = collectExperimentLinks(hdfName, includeParent)
% Get a list of all softlinks & targets in AOData HDF5 file
%
% Syntax:
%   T = aod.h5.collectExperimentLinks(hdfName)
%
% Inputs:
%   hdfName         string/char or aod.persistent.Experiment
%       The AOData HDF5 file or experiment
%
% Notes:
%   Parent links are excluded
%
% See also:
%   h5.collectSoftlinks

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        includeParent = false;
    end

    if isa(hdfName, 'aod.persistent.Experiment')
        hdfName = hdfName.hdfFileName;
    end

    out = h5tools.collectSoftlinks(hdfName);
    if ~includeParent
        out = out(~endsWith(out, "Parent"));
    end

    targets = string.empty();

    for i = 1:numel(out)
        linkTarget = h5tools.readlink(hdfName,...
            h5tools.util.getPathParent(out(i)),...
            h5tools.util.getPathEnd(out(i)));
        targets = cat(1, targets, linkTarget);
    end

    T = table(out, targets,...
        'VariableNames', {'Location', 'Target'});
    