classdef SiftRegistration < aod.builtin.registrations.RigidRegistration
% SIFTREGISTRATION
%
% Description:
%   Transformation matrix obtained from ImageJ's SIFT Registration plugin
%
% Parent:
%   aod.builtin.registrations.RigidRegistration
%
% Constructor:
%   obj = SiftRegistration(registrationDate, data, 'ReferenceID', ID)
%
% Required parameters:
%   ReferenceID             Epoch ID used as starting point
% Optional parameters:
%   All the parameters presented in the SIFT user interface
% -------------------------------------------------------------------------
    methods
        function obj = SiftRegistration(registrationDate, data, varargin)
            obj = obj@aod.builtin.registrations.RigidRegistration(...
                registrationDate, data);
           
            ip = aod.util.InputParser();
            addRequired(ip, 'ReferenceID', @isnumeric);
            % Whether stack was bleach-corrected first
            addParameter(ip, 'DUP', false, @islogical);
            % The default parameters for SIFT, only need to specify if one
            % of the defaults presented in ImageJ is changed
            addParameter(ip, 'InitialGaussianBlur', 1.6, @isnumeric);
            addParameter(ip, 'StepsPerScaleOctave', 3, @isnumeric);
            addParameter(ip, 'MinimumImageSize', 64, @isnumeric);
            addParameter(ip, 'MaximumImageSize', 1024, @isnumeric);
            addParameter(ip, 'FeatureDescriptorSize', 4, @isnumeric);
            addParameter(ip, 'FeatureDescriptorOrientationBins', 8, @isnumeric);
            addParameter(ip, 'ClosestNextClosestRatio', 4, @isnumeric);
            addParameter(ip, 'MaximalAlignmentRatio', 25, @isnumeric);
            addParameter(ip, 'InlierRatio', 0.05, @isnumeric);
            addParameter(ip, 'ExpectedTransformation', 'translation',...
                @(x) ismember(lower(x), {'translation', 'rigid', 'affine', 'similarity'}));
            addParameter(ip, 'Interpolate', true, @islogical);
            parse(ip, varargin{:});

            obj.setParam(ip.Results);
        end
    end
end