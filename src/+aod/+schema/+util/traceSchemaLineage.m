function fullName = traceSchemaLineage(schemaObj)
% Trace the lineage of a primitive or specification object
%
% Syntax:
%   obj = aod.schema.util.traceSchemaLineage(schemaObj)
%
% Inputs:
%   schemaObj - aod.schema.Primitive or aod.schema.Specification object

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if isSubclass(schemaObj, "aod.schema.Record")
        schemaObj = schemaObj.Primitive;
    end

    if isSubclass(schemaObj, "aod.schema.Specification")
        if isSubclass(schemaObj.Parent, "aod.schema.Specification")
            schemaObj = schemaObj.Parent;
        end
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
            "Input must be a record primitive, or specification, not %s.",...
            class(schemaObj));
    end

    schemaCollection = primitive.getParent('Collection');
    if isempty(schemaCollection)
        return
    end
    fullName = string(schemaCollection.recordType) + " = " + fullName;

    entity = schemaCollection.Parent;
    if isempty(entity)
        return
    end
    fullName = sprintf("""%s"" (%s)",...
        entity.groupName, string(entity.entityType)) + " \ " + fullName;
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