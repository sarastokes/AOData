function [ups, downs] = getModulationTimes(stim)
% GETMODULATIONTIMES
%
% Description:
%   Extract start and stop times for increments and decrements
%
% Syntax:
%   [ups, downs] = sara.util.getModulationTimes(stim)
%
% Notes:
%   The first value in the stimulus is assumed to be the baseline and 
%   modulations are extracted relative to that value
%
% History:
%   17Feb2022 - SSP
%   16Jul2022 - SSP - Generalized & renamed
% ---------------------------------------------------------------------

    stim = stim(:);
    
    bkgd = stim(1);
    changes = [0; diff(stim)];

    idx = find(changes ~= 0);
    idx = [idx; numel(stim)];

    ups = [];
    downs = [];
    for i = 1:numel(idx)-1
        newValue = stim(idx(i));
        if newValue > bkgd
            ups = cat(1, ups, [idx(i) idx(i+1)-1]);
        elseif newValue < bkgd
            downs = cat(1, downs, [idx(i) idx(i+1)-1]);
        end
    end

    if ~isempty(ups)
        ups = reshape(ups, [numel(ups)/2, 2]);
    end
    
    if ~isempty(downs)
        downs = reshape(downs, [numel(downs)/2, 2]);
    end
