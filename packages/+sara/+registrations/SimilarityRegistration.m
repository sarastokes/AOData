classdef SimilarityRegistration < aod.builtin.registrations.GeometricTransformation
% SIMILARITYREGISTRATION
%
% Description:
%   Similarity transformation registration
%
% Parent:
%   aod.builtin.registrations.GeometricTransformation
%
% Constructor:
%   obj = SimilarityRegistration(name, regDate)
%
% Properties (inherited):
%   transform
%   refObj
%
% Parameters:
%   OldSSIM
%   NewSSIM
%   RegFlag
%   Warning
%
% Methods:
%   data = apply(obj, data)
% -------------------------------------------------------------------------

    methods
        function obj = SimilarityRegistration(registrationDate, data, refObj, quality)
            obj@aod.builtin.registrations.GeometricTransformation(...
                'Similarity', registrationDate);
            
            if ~isa(data, 'simtform2d')
                data = simtform2d(data.Scale, data.RotationAngle, data.Translation);
            end
            obj.transform = data;

            if nargin > 2 && ~isempty(refObj)
                obj.reference = refObj;
            end

            if nargin > 3 && ~isempty(quality)
                obj.setParam('OldSSIM', quality.OldSSIM);
                obj.setParam('NewSSIM', quality.NewSSIM);
                obj.setParam('RegFlag', quality.RegFlag);
                obj.setParam('Warning', quality.Warning);
            end
        end
    
        function data = apply(obj, data)
            if isempty(obj.reference)
                refObj = imref2d([size(data,1), size(data,2)]);
            else
                refObj = obj.reference;
            end

            if ndims(data) == 2
                data = imwarp(data, refObj, obj.tform, 'OutputView', refObj);
            else
                % TODO: Check whether 3d conversion used for affine works here
                [x, y, t] = size(data);
                for i = 1:t
                    data(:,:,i) = imwarp(data(:,:,i), refObj,...
                        obj.tform, 'OutputView', refObj);
                end
            end
        end
    end
end