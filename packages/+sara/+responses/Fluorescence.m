classdef Fluorescence < aod.builtin.responses.RegionResponse
% FLUORESCENCE
%
% Description:
%   Wrapper for RegionResponses for fluorescence imaging
%
% Parent:
%   aod.builtin.responses.RegionResponses
%
% Constructor:
%   obj = Fluorescence(parent, annotation, varargin)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Fluorescence(parent, annotation, varargin)
            obj = obj@aod.builtin.responses.RegionResponse(...
                'Fluorescence', parent, annotation, varargin{:});
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('Epoch%u_Fluorescence', obj.Parent.ID);
        end
    end
end 