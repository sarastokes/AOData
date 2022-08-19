classdef Analysis < aod.core.Entity & matlab.mixin.Heterogeneous
% Analysis
%
% Description:
%   Implements data analysis. Meant to be expanded by subclasses
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Analysis(parent, analysisDate)
%
% Properties:
%   analysisParameters
%   analysisDate                date of analysis ('yyyyMMdd')
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
% -------------------------------------------------------------------------
    properties
        analysisParameters          = aod.core.Parameters
        analysisDate                datetime
    end

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Experiment'}
        parameterPropertyName = 'analysisParameters'
    end

    methods
        function obj = Analysis(parent, analysisDate)
            obj = obj@aod.core.Entity(parent);
            if nargin > 1
                obj.setAnalysisDate(analysisDate);
            end
        end
    end

    methods (Sealed)
        function setAnalysisDate(obj)
            % SETANALYSISDATE
            %
            % Syntax:
            %   setAnalysisDate(obj, analysisDate)
            %
            % Inputs:
            %   analysisDate            datetime, or char: 'yyyyMMdd'
            % -------------------------------------------------------------
            if ~isdatetime(analysisDate)
                try
                    analysisDate = datetime(analysisDate, 'Format', 'yyyyMMdd');
                catch ME 
                    if strcmp(ME.id, 'MATLAB:datestr:ConvertToDateNumber')
                        error("aod.core.Analysis/setAnalysisDate",...
                            "Failed to set analysisDate, use format yyyyMMdd");
                    else
                        rethrow(ME);
                    end
                end
            end
            obj.analysisDate = analysisDate;
        end
    end

end 