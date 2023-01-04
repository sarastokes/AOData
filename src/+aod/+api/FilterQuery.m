classdef (Abstract) FilterQuery < handle & matlab.mixin.Heterogeneous
% A filter for identifying entities (Abstract)
%
% Description:
%   Parent class for filtering entities in an AOData HDF5 file
%
% Parent:
%   handle, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.api.FilterQuery(hdfName)
%
% Abstract methods:
%   applyFilter(obj)
%
% Public methods:
%   names = getMatches(obj)
%
% Protected methods:
%   resetFilterIdx(obj)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Parent
    end

    properties (SetAccess = protected)
        localIdx
    end

    methods (Abstract)
        apply(obj)
    end

    methods
        function obj = FilterQuery(parent)
            arguments
                parent          {mustBeA(parent, 'aod.api.QueryManager')}
            end

            obj.Parent = parent;
        end
    end
end
