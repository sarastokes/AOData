classdef Analysis < aod.core.Entity & matlab.mixin.Heterogeneous
% ANALYSIS
%
% Description:
%   Implements data analysis. Meant to be expanded by subclasses
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Analysis(parent, name, analysisDate)
%
% Properties:
%   analysisDate                date of analysis ('yyyyMMdd')
% -------------------------------------------------------------------------
    properties
        analysisDate                datetime
    end

    methods
        function obj = Analysis(name, analysisDate)
            obj = obj@aod.core.Entity(name);
            if nargin > 1
                obj.setAnalysisDate(analysisDate);
            end
        end
    end

    methods (Sealed)
        function setAnalysisDate(obj, analysisDate)
            % SETANALYSISDATE
            %
            % Syntax:
            %   setAnalysisDate(obj, analysisDate)
            %
            % Inputs:
            %   analysisDate            datetime, or char: 'yyyyMMdd'
            % -------------------------------------------------------------
            if ~isdatetime(analysisDate) %#ok<*PROP> 
                try
                    analysisDate = datetime(analysisDate, 'Format', 'yyyyMMdd');
                catch ME 
                    if strcmp(ME.id, 'MATLAB:datestr:ConvertToDateNumber')
                        error("setAnalysisDate:FailedDatetimeConversion",...
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