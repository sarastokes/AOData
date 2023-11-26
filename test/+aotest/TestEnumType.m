classdef TestEnumType

    enumeration
        TYPEONE
        TYPETWO
        TYPETHREE
    end

    methods (Static)
        function obj = init(txt)
            try
                obj = aotest.TestEnumType.(upper(txt));
            catch
                error('init:UnrecognizedType',...
                    'Unrecognized type %s', txt);
            end
        end
    end
end