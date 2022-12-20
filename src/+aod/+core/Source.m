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
        Sources                         = aod.core.Source.empty()
    end

    methods
        function obj = Source(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
        end
    end

    methods (Sealed)
        function add(obj, childSource)
            % ADD
            %
            % Description:
            %   Add a sub-source to the current source
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

        function remove(obj, varargin)
            % REMOVE
            %
            % Description:
            %   Remove a child source, or sources
            %
            % Syntax:
            %   remove(obj, sourceID)
            % -------------------------------------------------------------

            if isscalar(obj)
                arrayfun(@(x) remove(x, varargin{:}), obj);
                return
            end

            if nargin == 3
                entityType = aod.core.EntityTypes.init(varargin{2});
                assert(entityType == aod.core.EntityTypes.SOURCE,...
                    'Only Sources can be removed from Source');
                ID = varargin{3};
            elseif nargin == 2
                ID = varargin{2};
            end

            if isnumeric(ID)
                mustBeInteger(ID); 
                mustBeInRange(ID, 1, numel(obj.Sources));
                ID = sort(ID, 'descend');
                obj.Sources(ID) = [];
            elseif istext(ID) && strcmpi(ID, 'all')
                obj.Sources = aod.core.Sources.empty();
            end
        end

        function allSources = getAllSources(obj)
            % GETALLSOURCES
            %
            % Description:
            %   Get all child sources of this source
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
            % GETPARENTS
            %
            % Description:
            %   Collect all source parents, with top-level listed first
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