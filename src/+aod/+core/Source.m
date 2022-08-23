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
%   obj = Source(parent, name);
%
% Methods:
%   sources = getParents(obj)
%   ID = getParentID(obj)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Experiment', 'aod.core.Source'}
    end

    methods
        function obj = Source(parent, name)
            obj = obj@aod.core.Entity(parent, name);
        end
    end

    methods (Sealed)
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

        function assignUUID(obj, UUID)
            % ASSIGNUUID
            %
            % Description:
            %   The same sources may be used over multiple experiments and
            %   should share UUIDs. This function provides public access
            %   to aod.core.Entity's setUUID function to facilitate hard-
            %   coded UUIDs for common sources
            %
            % Syntax:
            %   obj.assignUUID(UUID)
            %
            % See also:
            %   aod.util.generateUUID
            % -------------------------------------------------------------
            obj.setUUID(UUID);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            if isnumeric(obj.Name)
                value = num2str(obj.Name);
            else
                value = obj.Name;
            end
        end
    end
end