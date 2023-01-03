function T = summarizeMethods(className)

    mc = meta.class.fromName(className);

    methodNames = arrayfun(@(x) string(x.Name), mc.MethodList);
    methodClass = arrayfun(@(x) string(x.DefiningClass.Name), mc.MethodList);
    methodAccess = [];
    for i = 1:numel(mc.MethodList)
        if iscell(mc.MethodList(i).Access)
            methodAccess = cat(1, methodAccess, "class-limited");
        else
            methodAccess = cat(1, methodAccess, string(mc.MethodList(i).Access));
        end
    end
    isSealed = arrayfun(@(x) x.Sealed, mc.MethodList);

    T = table(methodNames, methodClass, methodAccess, isSealed,... 
        'VariableNames', {'Name', 'Class', 'Access', 'Sealed'});

