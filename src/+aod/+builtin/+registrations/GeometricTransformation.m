classdef (Abstract) GeometricTransformation < aod.core.Registration
% GEOMETRICTRANSFORMATION (Abstract)
%
% Description:
%   Any geometric transformation applied to register the data
%
% Parent:
%   aod.core.Registration
%
% Properties:
%   transform
%   reference
%
% Methods to be implemented by subclasses:
%   dataOut = apply(obj, dataIn, varargin)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        transform
        reference       % TODO: remove?
    end

    methods
        function obj = GeometricTransformation(name, registrationDate, varargin)
            obj = obj@aod.core.Registration(name, registrationDate, varargin{:});
        end

        function setTransform(obj, tform)
            obj.transform = tform;
        end

        function setReference(obj, ref)
            obj.reference = ref;
        end

        function data = apply(obj, data, varargin) %#ok<INUSD>
            error('Apply:NotYetImplemented',...
                'GeometricTransformation/apply must be implemented by subclasses');
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
            T2(2, 1) = T(2, 1);
            T2(1, 2) = T(1, 2);
            T2(4, 1) = T(3, 1);
            T2(4, 2) = T(3, 2);

            tform = affine3d(T2);
        end
    end

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Registration(value);

            value.set("transform", "NUMBER",...
                "Size", "(3,3)",...
                "Description", "The transformation matrix");
        end
    end
end