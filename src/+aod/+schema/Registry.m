classdef Registry < handle
% REGISTRY
%
% Description:
%   A registry of all AOData class schemas on search path
%
% Constructor:
%   obj = aod.schema.Registry()
%
% Methods:
%   S = getSchema(obj, className)
%   tf = isUuidValid(obj, className)
%   printDetails(obj)

% By Sara Patterson, 2024 (AOData)
% --------------------------------------------------------------------------

    properties (SetAccess = private)
        Schemas         struct
        ClassTable      table
    end

    properties (Dependent)
        packages        string
    end

    methods
        function obj = Registry()
            obj.ClassTable = aod.schema.util.collectRegistries();
            obj.Schemas = aod.schema.util.collectAllSchemas();
        end

        function value = get.packages(obj)
            value = obj.getTopPackages();
        end

        function out = getSchema(obj, className)
            out = getNestedField(obj.Schemas, className);
        end

        function tf = isUuidValid(obj, className)
            registeredUUID = obj.ClassTable.UUID(obj.ClassTable.Name == className);
            schema = obj.getSchema(className);
            loggedUUID = schema.UUID;
            existingUUID = aod.infra.UUID.getClassUUID(className);
            tf = isequal(loggedUUID, existingUUID) & isequal(registeredUUID, existingUUID);
        end

        function printDetails(obj)
            % make customdisplay later
            pkgs = obj.getTopPackages();
            fprintf('%u classes from %u top-level package(s): %s\n',...
                height(obj.ClassTable), numel(pkgs), value2string(pkgs));
        end
    end

    methods (Access = private)
        function pkgs = getTopPackages(obj)
            pkgs = arrayfun(@(x) obj.topPkgFcn(x), obj.ClassTable.Name);
            pkgs = unique(pkgs)';
        end
    end

    methods (Static, Access = private)
        function out = topPkgFcn(className)
            txt = strsplit(className, ".");
            out = txt(1);
        end
    end
end