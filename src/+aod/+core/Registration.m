classdef Registration < aod.core.Entity

    properties (SetAccess = private)
        Data
        registrationParameters
    end

    methods
        function obj = Registration(parent, data)
            obj.allowableParentTypes = {'aod.core.Epoch'};
            if nargin > 0
                obj.addParent(parent);
            end
            if nargin > 1
                obj.Data = data;
            end
        end
    end
end