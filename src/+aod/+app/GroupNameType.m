classdef GroupNameType
% Enumeration for different group name assignment approaches
%
% Static methods:
%   out = aod.app.GroupNameType.get('name')

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
            % Return the GroupNameType from text input of name
            if isa(txt, 'aod.app.GroupNameType')
                out = txt;
                return
            end

            import aod.app.GroupNameType

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
                    out = GroupNameType.Undefined;
            end
        end
    end
end