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
%   obj = aod.core.Annotation(name, varargin)
%   obj = aod.core.Annotation(name, 'Data', data, 'Source', source)
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
            addParameter(ip, 'Source', []);
            addParameter(ip, 'Date', getDateYMD(), @isdatetime);
            parse(ip, varargin{:});

            obj.setData(ip.Results.Data);
            obj.setSource(ip.Results.Source);
            obj.setDate(ip.Results.Date);
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
            % Sets the AnnotationDate attribute
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
                obj.setAttr('AnnotationDate', datetime.empty());
            end
            annotationDate = aod.util.validateDate(annotationDate);
            obj.setAttr('AnnotationDate', annotationDate);
        end
    end
    
    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();

            value.add('Administrator', string.empty(), @isstring,... 
                'Who performed the annotation');
            value.add('AnnotationDate', datetime.empty(), @isdatetime,...
                'Date annotation was performed');
        end

        function value = specifyAttributes2()
            value = specifyAttributes2@aod.core.Entity();
            
            value.add("Administrator",...
                "Class", "string",...
                "Size", "(1,1)",...
                "Description", "The person(s) who performed the annotation");
            value.add("Software",...
                "Class", "string",...
                "Size", "(1,1)",...
                "Description", "Software used for the registration");
            value.add("AnnotationDate",...
                "Class", "datetime",...
                "Size", "(1,1)",...
                "Description", "The date the annotation was performed");
        end
    end
end
