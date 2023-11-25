classdef List < aod.schema.primitives.Container
% LIST
%
% Superclasses:
%   aod.schema.primitives.Container
%
% Constructor:
%   obj = aod.schema.primitives.List(parent, varargin)
%
% Options:
%   Class, Items, Default, Description

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Count           aod.schema.validators.Count
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.LIST
        OPTIONS = ["Class", "Items", "Default", "Description"];
        VALIDATORS = ["Class", "Count"] % SIZE
    end

    methods
        function obj = List(parent, varargin)
            obj = obj@aod.schema.primitives.Container(parent);

            % Initialize
            obj.Count = aod.schema.validators.Count(obj, []);

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function setCount(obj, ID)
            arguments
                obj
                ID          {mustBeInteger, mustBePositive}
            end
            obj.Count.setValue(ID);
            obj.checkIntegrity(true);
        end
    end

    methods
        function removeItem(obj, ID)
            removeItem@aod.schema.primitives.Container(obj, ID);

            obj.setCount(obj.numItems);
        end
    end

    methods
        function [tf, ME, excObj] = checkIntegrity(obj, throwError)
            arguments
                obj
                throwError     (1,1)   logical = false
            end

            if obj.isInitializing || isempty(obj.Collection)
                return
            end

            [~, ~, excObj] = checkIntegrity@aod.schema.primitives.Container(obj);
            if obj.Count.isSpecified && obj.Count.Value ~= obj.numItems
                excObj.addCause(MException('checkIntegrity:ItemsDoNotMatchCount',...
                    'The number of specified items (%u) does not match Count (%u)',...
                    obj.numItems, obj.Count.Value));
            end

            tf = ~excObj.hasErrors();
            ME = excObj.getException();
            if excObj.hasErrors && throwError
                throw(ME);
            end
        end
    end

    methods (Access = protected)
        function doAddItem(obj, newItem)
            doAddItem@aod.schema.primitives.Container(obj, newItem);

            obj.setCount(obj.numItems);
        end

        function newItem = createItem(obj, type, varargin)
            if isempty(obj.Parent)
                parentName = "Unknown";
            else
                parentName = obj.Parent.Name;
            end
            name = sprintf("%s_%u", parentName, obj.numItems+1);
            newItem = createItem@aod.schema.primitives.Container(obj, name, type, varargin{:});
        end
        
        % function p = createPrimitive(obj, type, varargin)
        %     name = sprintf('%s_%u', obj.obj.numItems+1);
        %     newItem = Item()
        %     p = createPrimitive@aod.schema.primitives.Container(obj,...
        %         type, varargin{:});
        % end
    end
end
