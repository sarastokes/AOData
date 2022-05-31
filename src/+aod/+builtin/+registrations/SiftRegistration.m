classdef SiftRegistration < aod.core.Registration 

    methods
        function obj = SiftRegistration(parent, data)
            if ~isa(data, 'affine2d')
                data = affine2d(data);
            end
            obj@aod.core.Registration(parent, data);
        end
    end
end 