function [validators, decorators] = getValidatorsAndDecorators(obj)
    if istext(obj)
        mc = meta.class.fromName(obj);
    else
        mc = metaclass(obj);
    end

    out = arrayfun(@(x) getValidationClass(x), mc.PropertyList);
    validatorIdx = find(contains(out, '.validators.')); % TODO: isSubclass
    decoratorIdx = find(contains(out, '.decorators.'));
    validators = arrayfun(@(x) string(x.Name), mc.PropertyList(validatorIdx));
    decorators = arrayfun(@(x) string(x.Name), mc.PropertyList(decoratorIdx));
end

function out = getValidationClass(prop)
    
    if  isempty(prop.Validation) || isempty(prop.Validation.Class)
        out = "N/A";
    else
        out = string(prop.Validation.Class.Name);
    end

end