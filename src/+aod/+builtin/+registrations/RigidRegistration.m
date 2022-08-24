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
%   obj = RigidRegistration(data, varargin)
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
% -------------------------------------------------------------------------

    methods
        function obj = RigidRegistration(registrationDate, data, varargin)
            if ~isa(data, 'affine2d')
                try
                    data = affine2d(data);
                catch ME
                    if strcmp(ME.identifier, 'MATLAB:affine2d:set:T:incorrectSize')
                        error("RigidRegistration:IncorrectSize",...
                            'Transformation matrix was not 3x3 as expected');
                    end
                end

            end
            obj@aod.core.Registration(registrationDate, data);

            % Additional inputs are added to parameters
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