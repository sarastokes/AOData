classdef Namespace < handle
% NAMESPACE
%
% Description:
%   Represents and manages a single AOData namespace
%
% Static methods:
%   T = aod.infra.Namespace.readTable(fPath)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        pkgName             string
        metaPackage         meta.package
        filePath            string
        Table               table
        isPersisted         logical
    end

    properties (Dependent)
        registryPath        string
    end

    methods
        function obj = Namespace(filePath)
            arguments
                filePath    (1,1)   string      {mustBeFolder}
            end

            obj.filePath = filePath;

            txt = string(strsplit(filePath, filesep));
            txt = txt(arrayfun(@(x) startsWith(x, '+'), txt));
            if isempty(txt)
                error('Namespace:InvalidPackage',...
                    'No package folders beginning with + were identified');
            end
            obj.pkgName = erase(strjoin(txt, "."), "+");
            try
                obj.metaPackage = meta.package.fromName(obj.pkgName);
            catch
                error('Namespace:InvalidPackage', 'Invalid package name %s', obj.pkgName);
            end

            obj.Table = obj.assembleNamespaceTable();
            obj.isPersisted = false;
        end
    end

    methods
        function value = get.registryPath(obj)
            value = fullfile(obj.filePath, 'resources', 'registry.txt');
        end
    end

    methods
        function persistNamespaceTable(obj)
            if ~isfolder(fullfile(obj.filePath, "resources"))
                mkdir(fullfile(obj.filePath, "resources"));
            end
            if isfile(obj.registryPath)
                T = obj.readNamespaceTable(obj.registryPath);
                if ~isequal(T, obj.Table)
                    obj.writeTable();
                else
                    fprintf('Namespace %s is up to date\n', obj.pkgName);
                end
            else
                obj.writeTable();
            end
            obj.isPersisted = true;
        end

        function writeTable(obj)
            writetable(obj.Table, obj.registryPath, "Delimiter", "\t");
            fprintf('Updated namespace %s\n', obj.pkgName);
        end
    end

    methods (Access = private)
        function T = assembleNamespaceTable(obj)
            classList = arrayfun(@(x) string(x.Name), obj.metaPackage.ClassList);
            isEntity = arrayfun(@(x) isSubclass(x, 'aod.core.Entity'), classList);
            classList = classList(isEntity);
            if aod.util.isempty(classList)
                warning('Namespace:NoEntities',...
                    'No entities were found in the package %s', obj.pkgName);
                T = table.empty();
                return
            end
            fprintf("Found %u classes in %s", numel(classList), obj.pkgName);
            uuids = arrayfun(@(x) aod.infra.UUID.getClassUUID(x), classList);
            T = table(repmat(obj.pkgName, [numel(classList), 1]),...
                classList, uuids, false(size(classList)),...
                'VariableNames', {'Package', 'Class', 'UUID', 'Alias'});

        end
    end

    methods (Static)
        function T = readNamespaceTable(fPath)
            % READNAMESPACETABLE
            %
            % Inputs:
            %   fPath           string
            %       File path for registry.txt or folder path
            % -------------------------------------------------------------

            arguments
                fPath   (1,1)   string
            end

            if isfolder(fPath) && ~endsWith("resources")
                fPath = fullfile(fPath, "resources", "registry.txt");
            end

            T = readtable(fPath, "Delimiter", "\t");
            T.Package = string(T.Package);
            T.Class = string(T.Class);
            T.UUID = string(T.UUID);
        end
    end
end