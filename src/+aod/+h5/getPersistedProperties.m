function [persistedProps, attributeProps, abandonedProps, emptyProps] ...
        = getPersistedProperties(obj, verbose)
% Determine which properties will be persisted and which will not
%
% Syntax:
%   [persisted, attribute, abandoned, empty] = ...
%       aod.util.getPersistedProps(obj, verbose)
%
% Input:
%   obj             aod.core.Entity, class name or meta.class
%   verbose         logical (default = false)
%
% Output:
%   persistedProps      string
%       Names of properties written as datasets within the entity
%   attributeProps      string
%       Names of properties written as entity attributes
%   abandonedProps      string
%       Names of properties that are not written 
%   emptyProps          string
%       Names of properties that are empty (if an object was provided)
%
% See also:
%   aod.infra.getSystemAttributes, aod.infra.getSystemProperties

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        obj                 
        verbose             logical                             = false
    end

    
    if isa(obj, 'meta.class')
        mc = obj;
        isObject = false;
    elseif isobject(obj) && isSubclass(obj, 'aod.core.Entity')
        isObject = true;
        mc = metaclass(obj);
    elseif istext(obj)
        isObject = false;
        mc = meta.class.fromName(obj);
        assert(isSubclass(mc, 'aod.core.Entity'),...
            'Input must be a class name or instance of a class');
    end

    containerProps = aod.common.EntityTypes.allContainerNames();
   
    alwaysPersistedProps = ["notes", "Parent", "files", "description", "Name"];
    alwaysAttributeProps = ["UUID", "label", "parameters", "entityType", "dateCreated", "lastModified"];
    persistedProps = [];
    attributeProps = [];
    abandonedProps = [];

    for i = 1:numel(mc.PropertyList)
        if ismember(mc.PropertyList(i).Name, alwaysAttributeProps)
            attributeProps = cat(1, attributeProps,...
                string(mc.PropertyList(i).Name));
        elseif ismember(mc.PropertyList(i).Name, alwaysPersistedProps)
            persistedProps = cat(1, persistedProps,...
                string(mc.PropertyList(i).Name));
        elseif ismember(mc.PropertyList(i).Name, containerProps)
            % Containers are not persisted with containing entity
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        elseif ~strcmp(mc.PropertyList(i).GetAccess, 'public')
            % Properties without public get access are not available
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        elseif mc.PropertyList(i).Transient
            % Transient properties are akways abandoned
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        elseif mc.PropertyList(i).Dependent
            % Dependent properties are persisted unless hidden
            if mc.PropertyList(i).Hidden
                abandonedProps = cat(1, abandonedProps,...
                    string(mc.PropertyList(i).Name));
            else
                persistedProps = cat(1, persistedProps,...
                    string(mc.PropertyList(i).Name));
            end
        else
            persistedProps = cat(1, persistedProps,...
                string(mc.PropertyList(i).Name));
        end
    end

    % Find empty props, if a object was provided
    emptyProps = false(1, numel(persistedProps));
    if isObject
        for i = 1:numel(persistedProps)
            emptyProps(i) = isempty(obj.(persistedProps(i)));
        end
    end

    if verbose
        if isempty(persistedProps)
            fprintf('No properties persisted\n');
        else
            fprintf('Persisted properties:\n');
            for i = 1:numel(persistedProps)
                if ~emptyProps(i)
                    fprintf('\t%s\n', persistedProps(i));
                end
            end
        end

        if isempty(abandonedProps)
            fprintf('No properties abandoned\n');
        else
            fprintf('Abandoned properties:\n');
            for i = 1:numel(abandonedProps)
                fprintf('\t%s\n', abandonedProps(i));
            end
            for i = 1:numel(persistedProps) 
                if emptyProps(i)
                    fprintf('\t%s (empty)\n', persistedProps(i));
                end
            end
        end

        if isempty(attributeProps)
            fprintf('No properties are attributes\n');
        else
            fprintf('Attribute properties:\n');
            for i = 1:numel(attributeProps)
                fprintf('\t%s\n', attributeProps(i));
            end
        end
    end

    if ~isempty(emptyProps)
        idx = emptyProps;
        abandonedProps = cat(1, abandonedProps, persistedProps(idx));
        emptyProps = persistedProps(idx);
        persistedProps(idx) = [];
    end