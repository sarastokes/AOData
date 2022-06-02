classdef SiftRegistration < aod.core.Registration 
% SIFTREGISTRATION
%
% Description:
%   Transformation obtained from ImageJ SIFT Registration plugin
% -------------------------------------------------------------------------

    methods
        function obj = SiftRegistration(parent, data, varargin)
            if ~isa(data, 'affine2d')
                data = affine2d(data);
            end
            obj@aod.core.Registration(parent, data);

            obj.addParameter(varargin{:});
        end
    end
end 