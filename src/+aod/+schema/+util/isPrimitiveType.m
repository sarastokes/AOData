function tf = isPrimitiveType(obj, primitiveType)

    primitiveType = aod.schema.primitives.PrimitiveType.get(primitiveType);

    if isSubclass(obj, 'aod.schema.Entry')
        tf = obj.primitiveType == primitiveType;
    elseif isSubclass(obj, 'aod.schema.primitives.Primitive')
        tf = obj.PRIMITIVE_TYPE == primitiveType;
    else
        tf = false;
    end
