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
%   ID = getParentID(obj)
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
            % -------------------------------------------------------------
            assert(sourceID > 0 && sourceID <= numel(obj.Sources),...
                'Invalid source ID %u, must be between 1 and %u',...
                sourceID, numel(obj.Sources));
            obj.Sources(sourceID) = [];
        end

        function clearSources(obj)
            % CLEARSOURCES
            %
            % Syntax:
            %   Clear child sources of this source
            % -------------------------------------------------------------
            obj.Sources = aod.core.Source.empty();
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

        function ID = getParentID(obj)
            % GETPARENTID
            %
            % Description:
            %   Navigate up the source hierarchy to get parent source ID
            %
            % Syntax:
            %   ID = obj.getParentID();
            % -------------------------------------------------------------
            if isempty(obj.Parent) || ~isSubclass(obj.Parent, 'aod.core.Source')
                ID = obj.ID;
                return 
            end

            parent = obj.Parent;
            while isSubclass(parent.Parent, 'aod.core.Source')
                parent = parent.Parent;
            end
            ID = parent.ID;
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
end