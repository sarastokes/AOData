classdef GroupLoadState 
% GROUPLOADSTATE
%
% Description:
%   Defines the information that has been loaded for a specific H5 group
%
% Methods:
%   tf = hasName(obj)
%   tf = hasAttributes(obj)
%   tf = hasContents(obj)
% -------------------------------------------------------------------------
    enumeration 
        NONE 
        NAME 
        ATTRIBUTES
        CONTENTS 
    end

    methods 
        function tf = hasName(obj)
            import aod.app.GroupLoadState

            if obj == GroupLoadState.NONE 
                tf = false;
            else
                tf = true;
            end
        end

        function tf = hasContents(obj)
            import aod.app.GroupLoadState
            
            if obj == GroupLoadState.CONTENTS 
                tf = true;
            else
                tf = false;
            end
        end

        function tf = hasAttributes(obj)
            import aod.app.GroupLoadState
            
            switch obj
                case {GroupLoadState.NONE, GroupLoadState.NAME}
                    tf = false;
                otherwise
                    tf = true;
            end
        end
    end
end