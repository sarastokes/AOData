classdef ImagingLight < aod.core.Stimulus
    
    properties (SetAccess = private)
        Value
    end
    
    methods
        function obj = ImagingLight(parent, value)
            if nargin == 0
                parent = [];
            end
            obj@aod.core.Stimulus(parent);
            if nargin > 1
                obj.Value = value;
            end
        end
    end
end

