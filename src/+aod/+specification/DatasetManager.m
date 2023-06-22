classdef DatasetManager < aod.specification.SpecificationManager
% Organizes the dataset specifications for an AOData core class
%
% Constructor:
%   obj = aod.specification.DatasetManager(className)
%
% Static constructor to populate from metaclass information:
%   obj = aod.specification.DatasetManager.populate(className)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        specType = "Dataset"
    end

    methods 
        function obj = DatasetManager(className)
            if nargin < 1
                className = "Unknown";
            end
            obj = obj@aod.specification.SpecificationManager(className);
        end

        function add(obj, varargin)
            if istext(varargin{1})
                error('add:InvalidInput',...
                    'Ad-hoc property addition is not supported. Use set() to modify an existing property defined or inherited by the class.');
            else
                add@aod.specification.SpecificationManager(obj, varargin{:});
            end
        end
    end

    methods (Static)
        function obj = populate(className)
            % Populate and create a DatasetManager from a class name
            %
            % Syntax:
            %   obj = aod.specification.DatasetManager.populate(className)
            %
            % Inputs:
            %   className           string/char, meta.class, object
            %       Class (must be aod.core.Entity subclass)
            %
            % Examples:
            %   obj = aod.specification.DatasetManager.populate('aod.core.Epoch')
            % -------------------------------------------------------------
            
            if ~isSubclass(className, "aod.core.Entity")
                if isa(className, 'meta.class')
                    className = className.Name;
                end
                error('populate:InvalidInput',...
                    'Class %s is not a subclass of aod.core.Entity', className);
            end

            if istext(className)
                mc = meta.class.fromName(className);
            elseif isa(className, 'meta.class')
                mc = className;
            elseif isobject(className)
                mc = metaclass(className);
            else
                error('populate:InvalidInput',...
                    'Input must be class name or meta.class, not %s', ...
                    class(className));
            end

            propList = mc.PropertyList;
            classProps = aod.h5.getPersistedProperties(mc.Name);
            systemProps = aod.infra.getSystemProperties();

            obj = aod.specification.DatasetManager(mc.Name);
            for i = 1:numel(propList)
                % Skip system properties
                if ismember(propList(i).Name, systemProps)
                    continue
                end

                % Skip properties that will not be persisted
                if ~ismember(propList(i).Name, classProps)
                    continue
                end

                dataObj = aod.specification.Entry(propList(i));
                obj.add(dataObj);
            end
        end
    end
end 