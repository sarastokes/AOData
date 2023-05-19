classdef MatlabClass < aod.specification.Validator


% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Class   (1,:)       string = "[]"
    end

    methods
        function obj = MatlabClass(classes)
            if nargin < 1
                obj.Class = "[]";
                return
            end
            obj.Class = obj.parse(classes);
        end

        function tf = validate(obj, value)
            if obj.Class == "[]"
                tf = true;
                return
            end
            tf = any(arrayfun(@(x) isa(value, x), obj.Class));
        end

        function out = text(obj)
            if numel(obj.Class) > 1
                out = array2commalist(obj.Class);
            else
                out = obj.Class;
            end        
        end
    end

    methods (Static, Access = private)
        function classes = parse(input)

            arguments
                input       string 
            end

            if isscalar(input) && (isempty(input) || ismember(input, ["", "[]"]))
                return
            end

            if isscalar(input) && contains(input, ',')
                input = strsplit(input, ',');
                input = arrayfun(@strip, input);
            end

            classes = strings(1, numel(input));
            for i = 1:numel(input)
                if exist(input(i), 'builtin') || exist(input(i), 'class')
                    classes(i) = input(i);
                else
                    error('MatlabClass:UnidentifiedClass',...
                        'Class %s not recognized', input(i));
                end
            end
        end
    end
end