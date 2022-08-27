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
% Properties:
%   tform
%
% Inherited properties:
%   registrationDate
%
% Methods:
%   data = apply(obj, data)
%
% Inherited methods:
%   setRegistrationDate(obj, regDate)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        tform                   
    end

    methods
        function obj = RigidRegistration(registrationDate, data)
            obj@aod.core.Registration(registrationDate);

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
            obj.tform = data;
        end

        function data = apply(obj, data)
            if ndims(data) == 2
                refObj = imref2d([size(data, 1), size(data, 2)]);
                data = imwarp(data, refObj, obj.tform,...
                    'OutputView', refObj);
                return 
            end

            try
                tForm = affine2d_to_3d(obj.tform);
                viewObj = affineOutputView(size(data), tForm,...
                    'BoundsStyle', 'SameAsInput');
                data = imwarp(data, tForm, 'OutputView', viewObj);
            catch
                [x, y, t] = size(data);
                refObj = imref2d([x y]);
                for i = 1:t
                    data(:,:,i) = imwarp(data(:,:,i), refObj,...
                        obj.tform, 'OutputView', refObj);
                end 
                warning('RigidRegistration:UsedSlowProcess');
            end
        end
    end
end 