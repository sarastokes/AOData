classdef DefaultValue < aod.specification.Specification 

    properties
        Value           = []
    end

    methods
        function obj = DefaultValue(value, classSpec)
            if nargin > 1
                obj.checkClass(value);
            end
            if nargin > 0
                obj.Value = value;
            end
        end

        function tf = validate(obj, input)
            tf = true;
        end

        function out = text(obj)
            out = value2string(obj.Value);
        end

        function checkClass(obj, matlabClass)
            arguments
                obj
                matlabClass     aod.specification.MatlabClass 
            end

            tf = matlabClass.validate(obj.Value);
            if ~tf
                error('checkClass:DefaultValueDoesNotMatchClass',...
                    'Default value has class %s, not %s',...
                    class(obj.Value), matlabClass.Class);
            end
        end
    end
end