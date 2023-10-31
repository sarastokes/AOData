classdef Persistor < handle

    properties
        className
        packageName
        classFile
        jsonSchema
        jsonRepository

        Schema
    end

    methods
        function obj = Persistor(className)
            arguments
                className       string
            end

            obj = aod.schema.io.Standalone(className);
            obj.className = className;
            obj.packageName = erase(obj.className, getClassWithoutPackages(obj.className));

            obj.classFile = which(className);
            obj.validateFileLocation();
        end

        function getJsonSchemas(obj)
            fPath = fileparts(obj.classFile);
            if isfile(fullfile(fPath, "resources", "common.json"))
                obj.jsonSchema = readstruct(fullfile(fPath, "resources", "common.json"));
            else
                obj.jsonSchema = [];
            end
            if isfile(fullfile(fPath, "resources", "repository.json"))
                obj.jsonRepository = readstruct(fullfile(fPath, "resources", "repository.json"));
            else
                obj.jsonRepository = [];
            end
        end

        function isEqual = compareSchemas(obj)
            if isempty(obj.jsonSchema)
                isEqual = false;
            else
                isEqual = obj.Schema.compare(obj.jsonSchema);
            end
        end

        function update(obj)
            if isempty(obj.jsonSchema)
                % Send to function that creates the whole thing
                return
            end
            lastModified = datetime('now');
            % Increment the version number

            ID = [];  % Get from registry.txt
            S = obj.Schema.struct();
            S.VersionNumber = obj.jsonSchema.(obj.packageName).(ID).VersionNumber + 1;
            S.LastModified = lastModified;
            % Insert into schema struct: append or replace old version
            if isempty(ID)
                obj.jsonSchema.(obj.packageName) = catstruct(...
                    obj.jsonSchema.(obj.packageName), S);
            else
                %oldSchema = obj.jsonSchema.(obj.packageName).Classes(ID);
                obj.jsonSchema.(obj.packageName).Classes(ID) = S;
            end
            writestruct(jsonencode(S), fullfile(fPath, "resources", "current.json"));

            % Now place into the schema repository

        end

        function out = getClassNode(obj)
            if isempty(obj.jsonSchema)
                out = [];
            else
                out = obj.jsonSchema.(obj.packageName).Classes;
            end
        end
    end

    methods (Access = private)
        function validateFileLocation(obj)
            fPath = fileparts(obj.classFile);
            if ~isfolder(fullfile(fPath, "resources"))
                mkdir(fullfile(fPath, "resources"));
            end
        end
    end
end