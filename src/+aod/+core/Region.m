classdef Region < aod.core.Entity & matlab.mixin.Heterogeneous
% REGIONS
%
% Description:
%   Spatial regions within acquired data. Could be ROIs in a physiology 
%   experiment, coordinates of structures of interest, etc.
%
% Constructor:
%   obj = Region(parent, data, varargin)
%   obj = Region(parent, varargin)
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Properties:
%   Data                    
%
% Dependent properties:
%   count
%   roiIDs
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
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

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Experiment'};
    end

    methods
        function obj = Region(parent, varargin)
            obj = obj@aod.core.Entity();
            obj.setParent(parent);

            ip = aod.util.InputParser();
            addOptional(ip, 'Data', []);
            addParameter(ip, 'Source', [], @(x) isSubclass(x, 'aod.core.Source'));
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
                assert(isSubclass(source, 'aod.core.Source'), 'Must be a subclass of source');
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
            if isempty(obj.Data)
                obj.Data = [];
            else
                obj.Data = data;
            end
        end
    end
end
