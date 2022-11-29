classdef Source < aod.core.Entity & matlab.mixin.Heterogeneous
% SOURCE
%
% Description:
%   The source of data collected in an experiment
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Source(name)
%   obj = Source(name, parent)
%
% Methods:
%   sources = getParents(obj)
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
        function add(obj, subSource)
            % ADD
            %
            % Description:
            %   Add a sub-source to the current source
            %
            % Syntax:
            %   add(obj, subSource)
            % -------------------------------------------------------------
            assert(isSubclass(obj, 'aod.core.Source'),... 
                'Must be subclass of aod.core.Source');

            subSource.setParent(obj);
            obj.Sources = cat(1, obj.Sources, subSource);
        end

        function remove(obj, sourceID)
            % REMOVE
            %
            % Description:
            %   Remove a child source, or sources
            %
            % Syntax:
            %   remove(obj, sourceID)
            % -------------------------------------------------------------
            assert(sourceID > 0 && sourceID <= numel(obj.Sources),...
                'Invalid source ID %u, must be between 1 and %u',...
                sourceID, numel(obj.Sources));
            obj.Sources(sourceID) = [];
        end

        function clearSources(obj)
            % CLEARSOURCES
            %
            % Description:
            %   Clear child sources of this source
            %
            % Syntax:
            %   clearSources(obj)
            % -------------------------------------------------------------
            obj.Sources = aod.core.Source.empty();
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