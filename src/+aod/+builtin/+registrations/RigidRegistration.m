classdef RigidRegistration < aod.builtin.registrations.GeometricTransformation
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
%   transform
%
% Inherited properties:
%   registrationDate
%
% Methods:
%   data = apply(obj, data)
%
% Static methods:
%   tform = affine2d_to_3d(tform)
%
% Inherited methods:
%   setDate(obj, regDate)
%
% Dependencies:
%   Image Processing Toolbox

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = RigidRegistration(name, registrationDate, data, varargin)
            obj@aod.builtin.registrations.GeometricTransformation(name, registrationDate, varargin{:});

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
            obj.setTransform(data);
        end

        function data = apply(obj, data, varargin)
            if ismatrix(data)
                refObj = imref2d([size(data, 1), size(data, 2)]);
                data = imwarp(data, refObj, obj.tform,...
                    'OutputView', refObj, varargin{:});
            else
                tForm = obj.affine2d_to_3d(obj.tform);
                viewObj = affineOutputView(size(data), tForm,...
                    'BoundsStyle', 'SameAsInput');
                data = imwarp(data, tForm, 'OutputView', viewObj, varargin{:});
            end
            % Add optional key/value inputs to imwarp to attributes
            if nargin > 2
                obj.setAttr(varargin{:});
            end
        end
    end
end 