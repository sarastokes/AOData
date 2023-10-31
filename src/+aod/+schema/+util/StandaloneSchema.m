classdef StandaloneSchema < aod.schema.Schema
% STANDALONESCHEMA
%
% Description:
%   This is an entity's schema created separately from the entity itself
%
% Constructor:
%   obj = aod.schema.util.StandaloneSchema(className)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = StandaloneSchema(className)
            obj = obj@aod.schema.Schema([]);

            if ~isSubclass(className, 'aod.core.Entity')
                error('StandaloneSchema:InvalidClass',...
                    'Only subclasses of aod.core.Entity have specifications');
            end
            obj.setClassName(className);
        end
    end

    % aod.schema.SchemaCollection methods
    methods (Access = protected)
        function value = getAttributeCollection(obj)
            if ~isempty(obj.AttributeCollection)
                value = obj.AttributeCollection;
                return
            end

            eval(sprintf('value = %s.specifyAttributes();', obj.className));
            value.setClassName(obj.className); %#ok<NODEF>
        end

        function value = getFileCollection(obj)
            if ~isempty(obj.FileCollection)
                value = obj.FileCollection;
                return
            end

            eval(sprintf('value = %s.specifyFiles();', obj.className));
            value.setClassName(obj.className); %#ok<NODEF>
        end

        function value = getDatasetCollection(obj)
            if ~isempty(obj.DatasetCollection)
                value = obj.DatasetCollection;
                return
            end

            value = aod.schema.collections.DatasetCollection.populate(obj.className);
        end
    end
end