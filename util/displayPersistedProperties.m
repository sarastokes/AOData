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

    alwaysPersistedProps = ["description", "notes", "label"]';
    persistedProps = [];
    abandonedProps = [];

    mc = metaclass(obj);
    for i = 1:numel(mc.PropertyList)
        if (numel(mc.PropertyList(i).SetAccess)>1 || ~strcmp(mc.PropertyList(i).SetAccess, 'private')) ...
                && ~mc.PropertyList(i).Hidden
            persistedProps = cat(1, persistedProps,...
                string(mc.PropertyList(i).Name));
        elseif ~ismember(mc.PropertyList(i).Name, alwaysPersistedProps)
            abandonedProps = cat(1, abandonedProps,...
                string(mc.PropertyList(i).Name));
        end
    end
    persistedProps = cat(1, persistedProps, alwaysPersistedProps);

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
            if ~ismember(abandonedProps(i), alwaysPersistedProps)
                fprintf('\t%s\n', abandonedProps(i));
            end
        end
    end
end