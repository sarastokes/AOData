classdef SubclassGenerator < handle
% Model for generating template subclass files
%
% Constructor:
%   obj = aod.app.models.SubclassGenerator(name)
%
% See also:
%   AODataSubclassCreator, aod.app.controllers.SubclassGeneratorController

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events 
        ChangedLinks
        ChangedDatasets
        ChangedAttributes 
    end

    properties 
        ClassName               string          {mustBeValidVariableName} = "Undefined"  
        FilePath                string
        SuperClass              string
        EntityType 

        groupNameMode           string          = "UserDefined"      
        userDefinedName         logical         = true
        defaultName             string          = string.empty()
        defineLabel             logical         = false
        
        overloadedMethods       string          = string.empty()
        overwrittenMethods      string          = string.empty()
    end

    properties (SetAccess = protected) 
        Datasets    aod.util.templates.PropertySpecification   = aod.util.templates.PropertySpecification.empty()
        Links       aod.util.templates.LinkSpecification       = aod.util.templates.LinkSpecification.empty()
        Attributes  aod.util.templates.AttributeSpecification  = aod.util.templates.AttributeSpecification.empty()
    end

    properties (Dependent)
        % Full file name and path for class
        classFileName
        classNameWithPackages
        isWriteable
        isViewable
        Properties
    end

    methods
        function obj = SubclassGenerator(name)
            if nargin > 0
                obj.ClassName = name;
            end
        end
    end
    
    % Dependent property set/get methods
    methods 
        function out = get.Properties(obj)
            if isempty(obj.Datasets) && isempty(obj.Links)
                out = [];
            elseif isempty(obj.Datasets)
                out = obj.Links;
            elseif isempty(obj.Links)
                out = obj.Datasets;
            else
                out = cat(1, obj.Datasets, obj.Links);
            end
        end

        function out = get.classNameWithPackages(obj)
            if isempty(obj.FilePath)
                out = obj.ClassName;
                return
            end

            out = ""; 
            txt = strsplit(obj.FilePath, filesep);
            tf = arrayfun(@(x) startsWith(x, "+"), txt);
            for i = 1:numel(tf)
                if tf(i)
                    out = out + txt(i); 
                end
            end
            out = out + obj.ClassName;

            % Turn into package name
            if startsWith(out, "+")
                out = getCharIdx(out, 2:strlength(out));
            end

            out = strrep(out, "+", ".");
        end

        function out = get.classFileName(obj)
            if isempty(obj.ClassName)
                out = string.empty();
                return
            end
            
            out = obj.ClassName + ".m";

            if isempty(obj.FilePath) || obj.FilePath == ""
                out = fullfile(pwd, out);
            else
                out = fullfile(obj.FilePath, out);
            end
        end

        function out = get.isWriteable(obj)
            if ~obj.isViewable || isempty(obj.FilePath)
                out = false;
            else
                out = true;
            end
        end

        function out = get.isViewable(obj)
            if isempty(obj.ClassName) || isempty(obj.SuperClass)
                out = false;
            else
                out = true;
            end
        end
    end

    % Properties and parameters
    methods
        function [dset, idx] = getDataset(obj, dsetName)
            out = arrayfun(@(x) x.Name, obj.Datasets);
            idx = find(out == dsetName);
            dset = obj.Datasets(idx);
        end

        function addDataset(obj, prop)
            % Add a property specification to the subclass
            %
            % Syntax:
            %   addDataset(obj, dset)
            %
            % Inputs:
            %   dset        aod.util.templates.PropertySpecification
            %       One or more property specifications
            % -------------------------------------------------------------
            arguments
                obj 
                prop        {mustBeA(prop, 'aod.util.templates.PropertySpecification')}
            end

            if isempty(obj.Datasets)
                obj.Datasets = prop;
            else
                if isrow(prop)
                    prop = prop';
                end
                obj.Datasets = cat(1, obj.Datasets, prop);
            end
            notify(obj, "ChangedDatasets");
        end

        function removeDataset(obj, propName)
            out = arrayfun(@(x) x.Name, obj.Datasets);
            idx = find(out == propName);
            obj.Datasets(idx) = [];
            notify(obj, "ChangedDatasets");
        end

        function clearDatasets(obj)
            if isempty(obj.Datasets)
                return
            end
            obj.Datasets(:) = [];
            notify(obj, "ChangedDatasets");
        end

        function addLink(obj, prop)
            arguments
                obj
                prop        {mustBeA(prop, 'aod.util.templates.LinkSpecification')}
            end

            if isempty(obj.Links)
                obj.Links = prop;
            else
                obj.Links = cat(1, obj.Links, prop);
            end
            notify(obj, "ChangedLinks");
        end

        function removeLink(obj, linkName)
            out = arrayfun(@(x) x.Name, obj.Links);
            idx = find(out == linkName);
            obj.Links(idx) = [];
            notify(obj, "ChangedLinks");
        end

        function clearLinks(obj)
            if isempty(obj.Links)
                return
            end
            obj.Links(:) = [];
            notify(obj, "ChangedLinks");
        end

        function addAttribute(obj, attr)
            arguments
                obj
                attr        {mustBeA(attr, 'aod.util.templates.AttributeSpecification')}
            end

            obj.Attributes = cat(1, obj.Attributes, attr);
            notify(obj, "ChangedAttributes");
        end

        function removeAttribute(obj, attrName)
            out = arrayfun(@(x) x.Name, obj.Attributes);
            idx = find(out == attrName);
            obj.Attributes(idx) = [];
            notify(obj, "ChangedAttributes");
        end

        function clearAttributes(obj)
            if isempty(obj.Attributes)
                return
            end
            obj.Attributes = aod.util.templates.AttributeSpecification.empty();
            notify(obj, "ChangedAttributes");
        end
    end

    % Set methods for required properties
    methods
        function set.ClassName(obj, value)
            arguments
                obj 
                value        string     {mustBeValidVariableName}
            end

            assert(~isempty(value), 'ClassName must not be empty');
            assert(isletter(getCharIdx(value, 1)),...
                'MATLAB class names must begin with a letter');
            obj.ClassName = value;
        end

        function set.FilePath(obj, filePath)
            arguments
                obj 
                filePath    string      {mustBeFolder}
            end

            obj.FilePath = filePath;
        end

        function set.EntityType(obj, entityType)
            arguments
                obj 
                entityType      
            end

            obj.EntityType = aod.core.EntityTypes.get(entityType);
        end

        function set.SuperClass(obj, className)
            arguments
                obj
                className       string
            end
            
            assert(~isSubclass(className, 'aod.core.Entity'),...
                'Superclass must be a subclass of aod.core.Entity');
            obj.SuperClass = className; 
        end
    end

    % Group name types
    methods
        function set.groupNameMode(obj, value)
            arguments
                obj
                value 
            end
            obj.groupNameMode = aod.app.util.GroupNameType.get(value);
            % notify(obj, 'SetGroupNameMode');
        end
    end

    % Constructor specification methods
    methods
        function set.defaultName(obj, name)
            arguments
                obj
                name            string
            end

            obj.defaultName = name;
        end

        function set.userDefinedName(obj, flag)
            arguments
                obj
                flag            logical
            end

            obj.userDefinedName = flag;
        end

        function set.defineLabel(obj, flag)
            arguments
                obj
                flag            logical
            end

            obj.defineLabel = flag;
        end
    end

    % Inheritance methods
    methods
        function set.overloadedMethods(obj, value)
            arguments
                obj
                value           string
            end

            obj.overloadedMethods = value;
        end

        function set.overwrittenMethods(obj, value)
            arguments
                obj
                value           string
            end
            
            obj.overwrittenMethods = value;
        end
    end

    % Support methods
    methods
        function out = hasSetMethod(obj)
            if isempty(obj.Properties)
                out = [];
                return
            end
            out = logical.empty();
            for i = 1:numel(obj.Properties)
                out = cat(1, out, obj.Properties(i).makeSetFcn);
            end
            out = find(out);
        end 

        function out = getAllowableEntityTypes(obj) %#ok<MANU> 
            mc = meta.class.fromName('aod.core.EntityTypes');
            out = arrayfun(@(x) string(appbox.capitalize(x.Name)),... 
                mc.EnumerationMemberList);
        end

        function out = getAllowableSuperclasses(obj)
            classRepo = aod.infra.ClassRepository();
            coreClass = string(obj.EntityType.getCoreClassName());
            out = [coreClass; classRepo.get(coreClass)];
        end

        function out = getAllowableMethods(obj)
            T = summarizeMethods(obj.SuperClass);
            % Remove constructor
            T = T(2:end, :);
            % Remove unmodifiable methods
            T = T(~T.Sealed, :);
            T = T(T.Access == "public" | T.Access == "protected", :);
            % Remove mixin methods
            ignoredClasses = ["handle", "matlab.mixin.Heterogeneous",...
                "matlab.mixin.CustomDisplay"];
            T = T(~ismember(T.Class, ignoredClasses),:);
            out = T;
        end
    end
end 