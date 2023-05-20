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
% Static methods:
%   tform = affine2d_to_3d(tform)
%
% Inherited methods:
%   setDate(obj, regDate)
%
% Dependencies:
%   Image Processing Toolbox

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        tform                   
    end

    methods
        function obj = RigidRegistration(name, registrationDate, data, varargin)
            obj@aod.core.Registration(name, registrationDate, varargin{:});

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

    methods (Static)
        function tform = affine2d_to_3d(T)
            % Converts affine2d to affine3d 
            %
            % Description:
            %   Converts affine2d to affine3d so a full video or stack of 
            %   images can be transformed without using a long for loop
            %
            % Syntax:
            %   tform = affine2d_to_3d
            %
            % Inputs:
            %   T           affine3d or 3x3 transformation matrix
            %       The affine transform matrix
            %
            % Outputs:
            %   tform       affine3d
            %       A 3D affine transform object 
            % -------------------------------------------------------------
            if isa(T, 'affine2d')
                T = T.T;
            end

            T2 = eye(4);
            T2(2,1) = T(2,1);
            T2(1,2) = T(1,2);
            T2(4,1) = T(3,1);
            T2(4,2) = T(3,2);
            
            tform = affine3d(T2);
        end
    end
end 