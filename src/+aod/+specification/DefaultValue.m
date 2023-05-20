classdef DefaultValue < aod.specification.Validator 

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value           = []
    end

    methods
        function obj = DefaultValue(value, classSpec)
            if nargin > 0
                obj.Value = value;
            end

            if nargin > 1
                obj.checkClass(classSpec);
            end
        end
    end

    methods 
        function setValue(obj, input)
            obj.Value = input;
        end

        function tf = validate(~, ~)
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
                    class(obj.Value), matlabClass.Value);
            end
        end
    end

    % MATLAB built-in methods
    methods 
        function tf = isempty(obj)
            tf = aod.util.isempty(obj.Value);
        end
    end
end