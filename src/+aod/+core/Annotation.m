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
% Sealed protected methods:
%   setData(obj, data)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data   
        % Source associated with the Annotation
        Source                      = aod.core.Source.empty()       
    end

    methods
        function obj = Annotation(name, varargin)
            obj@aod.core.Entity(name, varargin{:});

            % Parse inputs (save validation for set functions)
            ip = aod.util.InputParser();
            addOptional(ip, 'Data', []);
            addParameter(ip, 'Source', []);
            parse(ip, varargin{:});

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
    end
end
