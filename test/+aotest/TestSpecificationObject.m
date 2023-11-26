classdef TestSpecificationObject < handle

    properties
        PropA   (1,2)   double                                  = [3, 4]
        PropB   (:,1)   double 
        % This is PropC
        PropC           double  {mustBeInteger}                 = 1 
        % This is PropD
        PropD   (1,:)   string                                  = ""
        PropE   (2,2)           {mustBeInteger, mustBeNumeric}  = ones(2,2)
    end

    methods
        function obj = TestSpecificationObject()
        end
    end
end 