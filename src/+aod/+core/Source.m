classdef Source < aod.core.Entity & matlab.mixin.Heterogeneous
% SOURCE
%
% Description:
%   A class for the data's source
%
% Parent:
%   aod.core.Entity
%   matlab.mixin.Heterogeneous
%
% Properties:
%   sourceParameters                aod.core.Parameters
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        sourceParameters            % aod.core.Parameters
    end

    methods
        function obj = Source(parent)
            obj = obj@aod.core.Entity();
            obj.allowableParentTypes = {'aod.core.Experiment',...
                'aod.core.Source', 'aod.core.Subject', 'aod.core.Empty'};
            % Check if a parent input was supplied
            if nargin > 0
                obj.setParent(parent);
            end
            obj.sourceParameters = aod.core.Parameters();
        end
    end

    methods (Sealed)
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

        function addParameter(obj, varargin)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, value)
            %   obj.addParameter(paramName, value, paramName, value)
            %   obj.addParameter(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    obj.sourceParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.sourceParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
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
            %   generateUUID
            % -------------------------------------------------------------
            obj.setUUID(UUID);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            if isnumeric(obj.identifier)
                value = num2str(obj.identifier);
            else
                value = identifier;
            end
        end
    end
end