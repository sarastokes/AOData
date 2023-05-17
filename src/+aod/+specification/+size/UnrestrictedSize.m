classdef UnrestrictedSize < aod.specification.Size
% Absence of a specification, any size is allowed

    methods 
        function obj = UnrestrictedSize()
        end

        function tf = isvalid(~, ~)
            tf = true;
        end
    end
end 