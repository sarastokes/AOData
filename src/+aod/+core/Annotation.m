classdef Annotation < aod.core.Entity & matlab.mixin.Heterogeneous
% ANNOTATION
%
% Description:
%   Spatial regions within acquired data. Could be ROIs in a physiology 
%   experiment, coordinates of structures of interest, etc.
%
% Constructor:
%   obj = Annotation(name, varargin)
%   obj = Annotation(name, data, varargin)
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Properties:
%   Data                    
%
% Sealed protected methods:
%   setData(obj, data)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data   
        Source                      = aod.core.Source.empty()       
    end

    properties (Access = protected)
        Reader
    end

    methods
        function obj = Annotation(name, varargin)
            obj = obj@aod.core.Entity(name);

            ip = aod.util.InputParser();
            addOptional(ip, 'Data', []);
            addParameter(ip, 'Source', [],... 
                @(x) isSubclass(x, {'aod.core.Source', 'aod.persistent.Source'}));
            parse(ip, varargin{:});

            obj.setData(ip.Results.Data);
            obj.setSource(ip.Results.Source);
        end
    end

    methods (Sealed, Access = protected)
        function setSource(obj, source)
            % SETSOURCE
            %
            % Syntax:
            %   setSource(obj, source)
            % -------------------------------------------------------------
            if isempty(source)
                obj.Source = aod.core.Source.empty();
            else
                assert(isSubclass(source, {'aod.core.Source', 'aod.persistent.Source'}),... 
                    'Must be a subclass of source');
                obj.Source = source;
            end
        end

        function setData(obj, data)
            % SETDATA
            %
            % Description:
            %   Assigns Data property and derived metadata
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
