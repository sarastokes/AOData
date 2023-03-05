classdef TemporalAverage < aod.core.Response 
% Spatial image averaged over time
%
% Description:
%   Takes the average across the full imaging window, over time
%
% Parent:
%   aod.core.Response
%
% Constructor:
%   obj = TemporalAverage(name, parent, varargin)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = TemporalAverage(name, parent, varargin)
            obj = obj@aod.core.Response(name, 'Parent', parent);
            obj.extractResponse(varargin{:});
        end

        function out = loadData(obj) %#ok<MANU,STOUT> 
            error('loadData:NotYetImplemented',...
                'Subclasses must define how data is loaded')
        end

        function extractResponse(obj, varargin)
            imStack = obj.loadData(varargin{:});
            obj.setData(squeeze(mean(imStack, 3, 'omitnan')));
        end
    end
end