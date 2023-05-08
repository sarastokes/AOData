classdef GroupNameType
% Enumeration for different group name assignment approaches
%
% Static methods:
%   out = aod.app.util.GroupNameType.get('name')

% By Sara Patterson, 2023 (AOData)
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
            % Return the GroupNameType from text input of name
            if isa(txt, 'aod.app.util.GroupNameType')
                out = txt;
                return
            end

            import aod.app.util.GroupNameType

            switch lower(txt)
                case 'userdefined'
                    out = GroupNameType.UserDefined;
                case {'userdefinedwithdefault', 'default'}
                    out = GroupNameType.UserDefinedWithDefault;
                case 'hardcoded'
                    out = GroupNameType.HardCoded;
                case 'classname'
                    out = GroupNameType.ClassName;
                case 'definedinternally'
                    out = GroupNameType.DefinedInternally;
                otherwise
                    error("get:UnknownType", "GroupNameType not defined!");
            end
        end
    end
end