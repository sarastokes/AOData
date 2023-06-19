classdef Source < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% A Source in an HDF5 file
%
% Description:
%   Represents a persisted Source in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Source(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Source
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        SourcesContainer
    end

    methods
        function obj = Source(hdfFile, hdfName, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfName, factory);
        end
    end

    methods (Sealed)
        function tf = has(obj, entityType, varargin)
            % Search Source's child entities and return if matches exist
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria and return whether matches exist
            %
            % Syntax:
            %   tf = has(obj, entityType, varargin)
            %
            % Inputs:
            %   entityType          char or aod.common.EntityTypes
            % Optional inputs:
            %   One or more cells containing queries
            %
            % See also:
            %   aod.persistent.Source/get
            % -------------------------------------------------------------
            out = obj.get(entityType, varargin{:});
            tf = ~isempty(out);
        end

        function out = get(obj, varargin)
            % Search and access child Sources
            %
            % Syntax:
            %   out = get(obj, varargin)
            %
            % Notes:
            %   - Queries are documented in aod.common.EntitySearch
            %
            % See Also:
            %   aod.common.EntitySearch
            % -------------------------------------------------------------

            import aod.common.EntityTypes

            if isempty(obj.Sources)
                out = aod.persistent.Source.empty();
                return
            end

            try
                entityType = EntityTypes.get(varargin{1});
                startIdx = 2;
            catch
                entityType = EntityTypes.SOURCE;
                startIdx = 1;
            end

            if entityType ~= EntityTypes.SOURCE
                error('get:InvalidEntityType', ...
                'Entity must be a Source');
            end

            if nargin == startIdx
                out = obj.Sources;
                return
            end

            if iscell(varargin{startIdx})
                out = aod.common.EntitySearch.go(obj.Sources, varargin{startIdx:end});
            else
                error('get:InvalidInput', 'Input must be a cell')
            end
        end

        function obj = add(obj, entity)
            % ADD
            % 
            % Description:
            %   Add a Source to the Experiment and the HDF5 file
            %
            % Syntax:
            %   add(obj, source)
            % -------------------------------------------------------------
            arguments
                obj
                entity      {mustBeA(entity, 'aod.core.Source')}
            end

            entity.setParent(obj);
            obj.addEntity(entity);
        end
    end

    methods 
        function value = getLevel(obj)
            % Get source level within Source hierarchy
            %
            % Syntax:
            %   value = getLevel(obj)
            %
            % Examples:
            %   EXPT = loadExperiment('ToyExperiment.h5');
            %   value = EXPT.Sources(1)
            %   >> Returns 1
            %   value = EXPT.Sources(1).Sources(1)
            %   >> Returns 2
            % -------------------------------------------------------------

            if ~isscalar(obj)
                value = arrayfun(@(x) x.getLevel, obj);
                return
            end

            value = 1;
            parent = obj.Parent;

            while isSubclass(parent, 'aod.persistent.Source')
                value = value + 1;
                parent = parent.Parent;
            end
        end

        function out = getChildSources(obj)
            % Get all child sources of this source
            %
            % Syntax:
            %   out = getChildSources(obj)
            %
            % Examples:
            %   EXPT = loadExperiment('ToyExperiment.h5')
            %   out = EXPT.Sources(1).getChildSources();
            %   >> Returns OD and OS and locations
            % -------------------------------------------------------------

            if ~isscalar(obj)
                out = uncell(aod.util.arrayfun(@(x) getChildSources(x), obj));
                return
            end

            out = obj;

            if isempty(obj.Sources)
                return
            end

            for i = 1:numel(obj.Sources)
                out = cat(1, out, obj.Sources(i));
                out = obj.iterSource(obj.Sources(i), out);
            end
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);
            
            % Add user-defined datasets and links
            obj.populateDatasetsAsDynProps();
            obj.populateLinksAsDynProps();
        end

        function populateContainers(obj)
            obj.SourcesContainer = obj.loadContainer('Sources');
        end
    end

    
    methods (Sealed, Access = private)
        function allSources = iterSource(obj, source, allSources)
            % Used to recursively identify all Sources
            if isempty(source.Sources)
                return
            end
            for i = 1:numel(source.Sources)
                allSources = cat(1, allSources, source.Sources(i));
                allSources = iterSource(obj, source.Sources(i), allSources);
            end
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Sources(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SourcesContainer(idx));
            end
        end
    end
end 