classdef Fluorescence < aod.core.responses.RegionResponses
%
% Description:
%   Wrapper for aod.core.responses.RegionResponses
%
% See also:
%   aod.core.responses.RegionResponses()
% -------------------------------------------------------------------------
    methods
        function obj = Fluorescence(parent)
            obj = obj@aod.core.responses.RegionResponses(parent);
        end
    end

    methods (Access = protected)
        function value = getDisplayName(obj)
            value = sprintf('Epoch%u_Fluorescence', obj.Parent.ID);
        end
    end
end 