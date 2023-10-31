function fullName = traceSchemaLineage(schemaObj)

    if isSubclass(schemaObj, "aod.schema.Specification")
        fullName = string(getClassWithoutPackages(schemaObj));
        primitive = schemaObj.Parent;
        if isempty(primitive)
            return
        end
        fullName = getPrimitiveName(schemaObj) + " \ " + fullName;
    elseif isSubclass(schemaObj, "aod.schema.Primitive")
        fullName = getPrimitiveName(schemaObj);
        if isempty(schemaObj.Parent)
            return
        end
        primitive = schemaObj;
    else
        error("traceSchemaLineage:InvalidObjectType",...
            "Input must be a primitive or specification object.");
    end

    schemaCollection = primitive.getParent('Collection');
    if isempty(schemaCollection)
        return
    end
    fullName = schemaCollection.schemaType + " = " + fullName;

    entity = schemaCollection.Parent;
    if isempty(entity)
        return
    end
    fullName = sprintf("""%s"" (%s)", entity.groupName, string(entity.entityType)) + " \ " + fullName;
end

function out = getPrimitiveName(p)
    if isa(p, 'aod.schema.Specification')
        p = p.Parent;
    end
    if isempty(p)
        out = "";
        return
    end

    if p.isNested
        out = sprintf("""%s in %s"" (%s/%s)", p.Name, p.Parent.Name, ...
            string(p.PRIMITIVE_TYPE), string(p.Parent.PRIMITIVE_TYPE));
    else
        out = sprintf("""%s"" (%s)", p.Name, string(p.PRIMITIVE_TYPE));
    end
end