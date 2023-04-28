classdef (Abstract) GeometricTransformation < aod.core.Registration
% GEOMETRICTRANSFORMATION (Abstract)
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
% Methods to be implemented by subclasses:
%   dataOut = apply(obj, dataIn, varargin)
% -------------------------------------------------------------------------
    properties
        transform
        reference       
    end

    methods
        function obj = GeometricTransformation(name, registrationDate, varargin)
            obj = obj@aod.core.Registration(name, registrationDate, varargin{:});
        end
        
        function data = apply(obj, data, varargin) %#ok<INUSD> 
            error('Apply:NotYetImplemented',...
                'GeometricTransformation/apply must be implemented by subclasses');
        end
    end
end