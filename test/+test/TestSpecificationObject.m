classdef TestSpecificationObject < handle

    properties
        PropA   (1,2)   double = [3, 4]
        PropB   (:,1)   double 
        PropC           double 
    end

    methods
        function obj = TestSpecificationObject()
        end
    end
end 