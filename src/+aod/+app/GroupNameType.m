classdef GroupNameType
% 
% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    enumeration
        UserDefined
        UserDefinedWithDefault
        HardCoded
        ClassName
        DefinedInternally
        Undefined
    end

    methods (Static)
        function out = get(txt)
            if isa(txt, 'GroupNameType')
                out = txt;
                return
            end

            switch lower(txt)
                case 'userdefined'
                    out = GroupNameType.UserDefined;
                case {'userdefinedwithdefault', 'default'}
                case 'hardcoded'
                    out = GroupNameType.HardCoded;
                case 'classname'
                    out = GroupNameType.ClassName;
                case 'definedinternally'
                    out = GroupNameType.DefinedInternally;
                otherwise
                    out = GroupNameType.Undefined;
            end
        end
    end
end