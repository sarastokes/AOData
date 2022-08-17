function [persistedProps, attributeProps, abandonedProps] = displayPersistedProperties(obj, verbose)
% DISPLAYPERSISTEDPROPERTIES
%
% Description:
%   Check which properties will be persisted and which will not
%
% Syntax:
%   displayPersistedProperties(obj, verbose)
%
% Input:
%   obj             aod.core.Entity
%   verbose         logical (default = false)
%
% History:
%   08Jun2022 - SSP
%   16Aug2022 - SSP - Expanded to distinguish attribute properties
% -------------------------------------------------------------------------

    arguments
        obj                 {mustBeA(obj, 'aod.core.Entity')}
        verbose             logical                             = false
    end

    entityType = aod.core.EntityTypes.get(obj);
    containerProps = entityType.containers();
    
    alwaysPersistedProps = ["notes", "Parent"]';
    alwaysAttributeProps = ["UUID", "description"];
    alwaysAbandonedProps = ["allowableParentTypes"];
    persistedProps = [];
    attributeProps = [];
    abandonedProps = [];

    mc = metaclass(obj);
    for i = 1:numel(mc.PropertyList)
        if ismember(mc.PropertyList(i).Name, alwaysAttributeProps)
            attributeProps = cat(1, attributeProps,...
                string(mc.PropertyList(i).Name));
        elseif ismember(mc.PropertyList(i).Name, alwaysPersistedProps)
            persistedProps = cat(1, persistedProps,...
                string(mc.PropertyList(i).Name));
        elseif ismember(mc.PropertyList(i).Name, alwaysAbandonedProps)
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        elseif ismember(mc.PropertyList(i).Name, containerProps)
            % Containers are not persisted
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        elseif contains(mc.PropertyList(i).Name, 'Parameters')
            % Properties with "parameters" in the name are attributes
            attributeProps = cat(1, attributeProps,...
                string(mc.PropertyList(i).Name));
        elseif mc.PropertyList(i).Dependent
            % Dependent properties are not persisted
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        elseif mc.PropertyList(i).Transient
            % Transient properties are not persisted
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        else
            persistedProps = cat(1, persistedProps,...
                string(mc.PropertyList(i).Name));
        end
    end

    if verbose
        if isempty(persistedProps)
            fprintf('No properties persisted\n');
        else
            fprintf('Persisted properties:\n');
            for i = 1:numel(persistedProps)
                fprintf('\t%s\n', persistedProps(i));
            end
        end

        if isempty(abandonedProps)
            fprintf('No properties abandoned\n');
        else
            fprintf('Abandoned properties:\n');
            for i = 1:numel(abandonedProps)
                fprintf('\t%s\n', abandonedProps(i));
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
end