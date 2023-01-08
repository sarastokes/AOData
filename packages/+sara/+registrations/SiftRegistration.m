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
%   obj = SiftRegistration(registrationDate, data, ID)
%
% Required parameters:
%   ReferenceID             Epoch ID used as starting point
% Optional parameters:
%   All the parameters presented in the SIFT user interface
% -------------------------------------------------------------------------
    methods
        function obj = SiftRegistration(registrationDate, data, varargin)
            obj = obj@aod.builtin.registrations.RigidRegistration(...
                'SIFT', registrationDate, data, varargin{:});
           
            obj.setParam('Software', 'ImageJ-SIFTRegistrationPlugin');
        end
    end

    methods (Access = protected)
        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.builtin.registrations.RigidRegistration(obj);
            
            value.add('ReferenceID', [], @isnumeric,...
                'Epoch ID used as template for registration');
            value.add('HistogramMatching', false, @islogical,...
                'Whether Histogram Matching was performed first.');
            value.add('WhichStack', 'SUM', @isstring);

            % The default parameters for SIFT, only need to specify if one
            % of the defaults presented in ImageJ is changed
            value.add('InitialGaussianBlur', 1.6, @isnumeric);
            value.add('StepsPerScaleOctave', 3, @isnumeric);
            value.add('MinimumImageSize', 64, @isnumeric);
            value.add('MaximumImageSize', 1024, @isnumeric);
            value.add('FeatureDescriptorSize', 4, @isnumeric);
            value.add('FeatureDescriptorOrientationBins', 8, @isnumeric);
            value.add('ClosestNextClosestRatio', 4, @isnumeric);
            value.add('MaximalAlignmentRatio', 25, @isnumeric);
            value.add('InlierRatio', 0.05, @isnumeric);
            value.add('ExpectedTransformation', 'rigid',...
                @(x) ismember(lower(x), ["translation", "rigid", "affine", "similarity"]));
            value.add('Interpolate', true, @islogical);
        end
    end
end