classdef RigidRegistration < aod.core.Registration 
% RIGIDREGISTRATION
%
% Description:
%   Any registration that outputs a standard transformation matrix
%
% Parent:
%   aod.core.Registration
%
% Constructor:
%   obj = RigidRegistration(parent, data, varargin)
%
% Inherited properties:
%   Data
%   registrationDate
%
% Methods:
%   imStack = apply(obj, imStack)
%
% Inherited methods:
%   setRegistrationDate(obj, regDate)
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------

    methods
        function obj = RigidRegistration(parent, data, varargin)
            if ~isa(data, 'affine2d')
                data = affine2d(data);
            end
            obj@aod.core.Registration(parent, data);

            % Additional inputs are added to registrationParameters
            obj.setParam(varargin{:});
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