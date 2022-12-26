classdef SpatialAverage < aod.core.Response
% Timecourse averaged over space
%
% Description:
%   Takes the average across the full imaging window, over time
%
% Parent:
%   aod.core.Response
%
% Constructor:
%   obj = SpatialAverage(name, parent, varargin)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

%TODO: Window?

    methods
        function obj = SpatialAverage(name, parent, varargin)
            obj = obj@aod.core.Response(name, 'Parent', parent);
            obj.extractResponse(varargin{:});
        end

        function out = loadData(obj)
            error('loadData:NotYetImplemented',...
                'Subclasses must define how data is loaded')
        end

        function extractResponse(obj, varargin)
            imStack = obj.loadData(varargin{:});
            obj.setData(squeeze(mean(imStack, [1 2], 'omitnan')));
        end
    end
end