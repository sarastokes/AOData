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
% Attributes:
%   Date                    datetime or text in format 'yyyyMMdd'
%       Date analysis was performed (default = today)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Date the analysis was performed
        analysisDate    datetime    {mustBeScalarOrEmpty} = datetime.empty()
    end

    methods
        function obj = Analysis(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Date', getDateYMD());
            parse(ip, varargin{:});

            if ~isempty(ip.Results.Date)
                obj.setDate(ip.Results.Date);
            end
        end
    end

    methods (Sealed)
        function setDate(obj, analysisDate)
            % Set the analysisDate property
            %
            % Syntax:
            %   setDate(obj, analysisDate)
            %
            % Inputs:
            %   analysisDate            datetime, or char: 'yyyyMMdd'
            % -------------------------------------------------------------
            if nargin == 1 || isempty(analysisDate)
                obj.analysisDate = datetime.empty();
                return
            end
            
            analysisDate = aod.util.validateDate(analysisDate);
            obj.analysisDate = analysisDate;
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();

            value.add("Administrator",...
                "Class", "string", "Size", "(1,1)",...
                "Description", "Person(s) who performed the analysis");
            value.add("Software",...
                "Class", "string", "Size", "(1,1)",...
                "Default", "MATLAB",...
                "Description", "Software used for the registration");
        end

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Entity(value);

            value.add("analysisDate",...
                "Class", "datetime", "Size", "(1,1)",...
                "Description", "The date the analysis was performed");
        end
    end
end 