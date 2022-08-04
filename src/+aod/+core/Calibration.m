classdef Calibration < aod.core.Entity & matlab.mixin.Heterogeneous
% CALIBRATION
%
% Description:
%   A calibration associated with the system or experiment
%
% Constructor:
%   obj = aod.core.Calibration(calibrationDate, parent)
%
% Parent:
%   aod.core.Entity
%   matlab.mixin.Heterogeneous
%
% Properties:
%   calibrationDate         date when the calibration was performed
%   calibrationParameters   aod.core.Parameters
%
% Sealed methods:
%   addParameter(obj, varargin)
%   setCalibrationDate(obj, calibrationDate)
%
% Note:
%   Inheriting matlab.mixin.Heterogeneous allows creation of arrays
%   containing different subclasses of aod.core.Calibration
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        calibrationDate(1,1)                datetime
        calibrationParameters               % aod.core.Parameters
    end

    methods
        function obj = Calibration(calibrationDate, parent)
            obj = obj@aod.core.Entity();
            obj.allowableParentTypes = {'aod.core.Dataset',... 
                'aod.core.System', 'aod.core.Empty'};
            
            if nargin > 0 && ~isempty(calibrationDate)
                if ~isa(calibrationDate, 'datetime')
                    obj.calibrationDate = datetime(calibrationDate,... 
                        'Format', 'yyyyMMdd');
                else
                    obj.calibrationDate = calibrationDate;
                end
            end

            if nargin > 1 && ~isempty(parent)
                obj.setParent(parent);
            end

            obj.calibrationParameters = aod.core.Parameters;
        end
    end

    methods (Sealed)
        function setCalibrationDate(obj, calDate)
            % SETCALIBRATIONDATE
            %
            % Description:
            %   Set the date where the calibration was performed
            % 
            % Syntax:
            %   obj.setCalibrationDate(calDate)
            % -------------------------------------------------------------
            if ~isdatetime(calDate)
                calDate = datetime(calDate, 'Format', 'yyyyMMdd');
            end
            obj.calibrationDate = calDate;
        end

        function addParameter(obj, varargin)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, value)
            %   obj.addParameter(paramName, value, paramName, value)
            %   obj.addParameter(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    obj.calibrationParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.calibrationParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
        end
    end
end

