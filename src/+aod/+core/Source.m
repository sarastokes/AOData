classdef Source < aod.core.Entity & matlab.mixin.Heterogeneous
% A source of acquired data
%
% Description:
%   The source of data collected in an experiment
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.Source(name)
%   obj = aod.core.Source(name, varargin)
%
% Methods:
%   sources = getParents(obj)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Container for Source's sub-Sources
        Sources                         = aod.core.Source.empty()
    end

    methods
        function obj = Source(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
        end
    end

    methods (Sealed)
        function add(obj, childSource)
            % Add a sub-source to the current source
            %
            % Syntax:
            %   add(obj, childSource)
            % -------------------------------------------------------------
            arguments 
                obj 
                childSource       {mustBeA(childSource, 'aod.core.Source')}
            end

            childSource.setParent(obj);
            obj.Sources = cat(1, obj.Sources, childSource);
        end

        function out = get(obj, varargin)
            % Search and access child Sources
            %
            % Syntax:
            %   out = get(obj, varargin)
            % -------------------------------------------------------------

            if isempty(obj.Sources)
                out = aod.core.Source.empty();
                return
            end
        
            import aod.core.EntityTypes

            try
                entityType = EntityTypes.get(varargin{1});
                if entityType ~= EntityTypes.SOURCE
                    error('get:InvalidEntityType',...
                        'Entity must be a Source');
                end
                startIdx = 2;
            catch
                startIdx = 1;
            end

            if nargin == startIdx
                out = obj.Sources;
                return
            end

            if iscell(varargin{startIdx})
                out = aod.core.EntitySearch.go(obj.Sources, varargin{startIdx:end});
            else
                error('get:InvalidInput', 'Input must be a cell')
            end
        end

        function remove(obj, varargin)
            % Remove child source(s) by ID , query or "all"
            %
            % Syntax:
            %   remove(obj, varargin)
            % -------------------------------------------------------------

            import aod.core.EntityTypes
            
            try 
                entityType = EntityTypes.get(varargin{1});
                startIdx = 2;
                assert(entityType == aod.core.EntityTypes.SOURCE,...
                    'Only Sources can be removed from Source');
            catch
                entityType = EntityTypes.SOURCE;
                startIdx = 1;
            end

            ID = varargin{startIdx};

            if isnumeric(ID)
                mustBeInteger(ID); 
                mustBeInRange(ID, 1, numel(obj.Sources));
                obj.Sources(ID) = [];
            elseif istext(ID) && strcmpi(ID, 'all')
                obj.Sources = aod.core.Source.empty();
            elseif iscell(ID)
                [~, ID] = aod.core.EntitySearch.go(obj.Sources, varargin{startIdx:end});
                if ~isempty(ID)
                    obj.Sources(ID) = [];
                else
                    warning('remove:NoQueryMatches',...
                        'No sources matched provided queries, none were removed');
                end
            else
                error('remove:InvalidID', 'Must be "all", indices or query cell(s)');
            end
        end

        function allSources = getAllSources(obj)
            % Get all child sources of this source
            %
            % Syntax:
            %   allSources = getAllSources(obj)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                allSources = uncell(aod.util.arrayfun(@(x) getAllSources(x), obj));
                return
            end

            allSources = obj;
            if isempty(obj.Sources)
                return
            end
            for i = 1:numel(obj.Sources)
                allSources = cat(1, allSources, obj.Sources(i));
                allSources = obj.iterSource(obj.Sources(i), allSources);
            end
        end

        function sources = getParents(obj)
            % Collect all source parents, with top-level listed first
            %
            % Syntax:
            %   ID = obj.getParents();
            % -------------------------------------------------------------
            sources = [];
            parent = obj.Parent;
            while ~isempty(parent) && isSubclass(parent, 'aod.core.Source')
                sources = cat(1, sources, parent);
                parent = parent.Parent;
            end
            % Ensure top-level is first
            if ~isempty(sources)
                sources = flipud(sources);
            end
        end
    end

    % Overloaded methods
    methods (Access = protected)    
        function value = getLabel(obj)  
            if ~isempty(obj.Parent) && isSubclass(obj.Parent, 'aod.core.Source')
                value = [obj.Parent.Name, '_', obj.Name];
            else
                value = obj.Name;
            end
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
end