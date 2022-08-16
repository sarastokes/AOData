function [idx, attributeValue] = findAttribute(info, attributeName)
    % FINDATTRIBUTE
    %
    % Syntax:
    %   [idx, attributeValue] = findAttribute(info, attributeName)
    % ---------------------------------------------------------------------
    arguments
        info                struct 
        attributeName       char 
    end

    if isempty(info.Attributes)
        idx = []; attributeValue = [];
        return
    end

    idx = arrayfun(@(x) strcmp(x.Name, attributeName), info.Attributes);
    idx = find(idx);

    if ~isempty(idx)
        attributeValue = info.Attributes(idx).Value;
        if iscell(attributeValue)
            attributeValue = cell2mat(attributeValue);
        end
    else
        attributeValue = [];
    end
