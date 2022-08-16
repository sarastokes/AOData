function displayPersistedProperties(obj)
    % DISPLAYPERSISTEDPROPERTIES
    %
    % Description:
    %   Check which properties will be persisted and which will not
    %
    % Syntax:
    %   displayPersistedProperties(obj)
    %
    % Input:
    %   obj             aod.core.Entity
    %
    % History:
    %   08Jun2022 - SSP
    % ---------------------------------------------------------------------
    
    assert(isSubclass(obj, 'aod.core.Entity'),...
        'displayPersistedProperties only valid for aod.core.Entity subclasses');

    alwaysPersistedProps = ["notes", "Parent"]';
    alwaysAttributeProps = ["UUID", "description"];
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
        elseif contains(mc.PropertyList(i).Name, 'Parameters')
            % Properties with "parameters" in the name are attributes
            attributeProps = cat(1, attributeProps,...
                string(mc.PropertyList(i).Name));
        elseif mc.PropertyList(i).Dependent
            % Dependent properties are not persisted
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        elseif (numel(mc.PropertyList(i).SetAccess)>1 || ~strcmp(mc.PropertyList(i).SetAccess, 'private')) ...
                && ~mc.PropertyList(i).Hidden
            persistedProps = cat(1, persistedProps,...
                string(mc.PropertyList(i).Name));
        else
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        end
    end

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