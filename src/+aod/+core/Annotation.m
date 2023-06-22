classdef Annotation < aod.core.Entity & matlab.mixin.Heterogeneous
% An annotation of acquired data
%
% Description:
%   Spatial regions within acquired data. Could be ROIs in a physiology 
%   experiment, coordinates of structures of interest, etc.
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.Annotation(name)
%   obj = aod.core.Annotation(name, annotationDate)
%   obj = aod.core.Annotation(name, annotationDate,...
%       'Data', data, 'Source', source)
%
% Inputs:
%   name            char or string
%       Annotation name
% Optional key/value inputs:
%   Data            
%       Data detailing the annotation locations
%   Source          aod.core.Source/aod.persistent.Source
%       The Source of the annotations
% Additional key/value inputs passed to aod.core.Entity
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Properties:
%   Data  
%   Source    
%
% Attributes
%   Administrator       string
%       Who performed the Annotation              
%
% Sealed protected methods:
%   setData(obj, data)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        annotationDate          datetime = datetime.empty();
        % The annotation data
        Data   
        % Source associated with the Annotation
        Source     {mustBeScalarOrEmpty, aod.util.mustBeEntityType(Source, 'Source')} = aod.core.Source.empty()       
    end

    methods
        function obj = Annotation(name, varargin)
            obj@aod.core.Entity(name, varargin{:});

            % Parse inputs (save validation for set functions)
            ip = aod.util.InputParser();
            addOptional(ip, 'Data', []);
            addParameter(ip, 'Date', getDateYMD(), @(x) isdatetime(x) || istext(x));
            addParameter(ip, 'Source', []);
            parse(ip, varargin{:});

            obj.setDate(ip.Results.Date);
            obj.setData(ip.Results.Data);
            obj.setSource(ip.Results.Source);
        end
    end

    methods (Sealed)
        function setSource(obj, source)
            % Set the Source associated with the annotation
            %
            % Syntax:
            %   setSource(obj, source)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                arrayfun(@(x) x.setSource(source), obj);
                return
            end
            
            if isempty(source)
                obj.Source = aod.core.Source.empty();
            else % Validate then add
                if ~isSubclass(source, {'aod.core.Source', 'aod.persistent.Source'})
                    error('setSource:InvalidEntityType',...
                        'Input must be an aod.core.Source or subclass.');
                end
                obj.Source = source;
            end
        end

        function setData(obj, data)
            % Assign Annotation's data 
            %
            % Description:
            %   Assigns Data property
            %
            % Syntax:
            %   obj.setData(data);
            % -------------------------------------------------------------
            if nargin < 2 || isempty(data)
                obj.Data = [];
            else
                obj.Data = data;
            end
        end

        function setDate(obj, annotationDate)
            % Change the annotation's date
            %
            % Syntax:
            %   setAnnotationDate(obj, annotationDate)
            %
            % Inputs:
            %   annotationDate      datetime, char/string in YYYYMMDD form
            %
            % Examples:
            %   obj.setAnnotationDate('20230318')
            % -------------------------------------------------------------
            if nargin < 2 || isempty(annotationDate)
                obj.annotationDate = datetime.empty();
                return
            end
            obj.annotationDate = aod.util.validateDate(annotationDate);
        end
    end
    
    methods (Static)

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Entity(value);
        
            value.set("annotationDate",...
                "Class", "datetime", "Size", "(1,1)",...
                "Description", "Date the annotation was performed");
        end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();
            
            value.add("Administrator",...
                "Class", "string",...
                "Size", "(1,1)",...
                "Description", "The person(s) who performed the annotation");
            value.add("Software",...
                "Class", "string",...
                "Size", "(1,1)",...
                "Description", "Software used for the registration");
        end
    end
end
