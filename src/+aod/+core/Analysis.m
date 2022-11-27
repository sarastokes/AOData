classdef Analysis < aod.core.Entity & matlab.mixin.Heterogeneous
% ANALYSIS
%
% Description:
%   Any analysis performed on experimental data, with implementation 
%   defined by subclasses.
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Analysis(name)
%   obj = Analysis(name, 'Date', analysisDate, 'Parent', entity)
%
% Parameters:
%   Date                    datetime or text in format 'yyyyMMdd'
%       Date analysis was performed (default = today)
% -------------------------------------------------------------------------

    methods
        function obj = Analysis(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Date', getDateYMD());
            parse(ip, varargin{:});

            if ~isempty(ip.Results.Date)
                obj.setAnalysisDate(ip.Results.Date);
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
            if nargin == 1 || isempty(analysisDate)
                obj.setParam('Date', '');
                return
            end
            
            analysisDate = aod.util.validateDate(analysisDate);
            obj.setParam('Date', analysisDate);
        end
    end

end 