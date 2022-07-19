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

        function imStack = apply(obj, imStack)
            try
                tform = affine2d_to_3d(obj.Data);
                viewObj = affineOutputView(size(imStack), tform,...
                    'BoundsStyle', 'SameAsInput');
                imStack = imwarp(imStack, tform, 'OutputView', viewObj);
            catch
                [x, y, t] = size(imStack);
                refObj = imref2d([x y]);
                for i = 1:t
                    imStack(:,:,i) = imwarp(imStack(:,:,i), refObj,...
                        obj.Data, 'OutputView', refObj);
                end 
            end
        end
    end
end 