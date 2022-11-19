classdef GeometricTransformation < aod.core.Registration
% GEOMETRICTRANSFORMATION
%
% Description:
%   Any geometric transformation applied to register the data
%
% Parent:
%   aod.core.Registration
%
% Properties:
%   transform
%   reference
% 
% -------------------------------------------------------------------------
    properties
        transform
        reference       
    end

    methods
        function obj = GeometricTransformation(name, registrationDate)
            obj = obj@aod.core.Registration(name, registrationDate);
        end
        
        function data = apply(obj, data) %#ok<INUSD> 
            error('Apply:NotYetImplemented',...
                'GeometricTransformation/apply must be implemented by subclasses');
        end
    end
end