classdef SchemaList < handle

    properties
        pkgName
        metaPackage
        resourceDir
        Table
    end

    methods
        function obj = SchemaList(pkgName)
            obj.pkgName = pkgName;
            obj.metaPackage = meta.class.fromName(pkgName);
            obj.resourceDir = aod.schema.util.getResourceDir(obj.pkgName, true);

            if ~isfile(fullfile(obj.resourceDir, "schema_list.txt"))
                obj.createTable();
            else
                obj.Table = readtable(fullfile(obj.resourceDir, "schema_list.txt"));
            end
        end

        function createTable(obj)
            classList = arrayfun(@(x) string(x.Name), obj.metaPackage.ClassList);
            classFiles = arrayfun(@(x) string(which(x)), classList);
            obj.Table = table(classList, classFiles,...
                'VariableNames', {'Class', 'File'});
        end
    end

    methods (Static)
        function out = findTable(pkgName)

        end
    end
end