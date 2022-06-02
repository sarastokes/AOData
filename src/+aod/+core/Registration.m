classdef Registration < aod.core.Entity
% REGISTRATION
%
% Description:
%   Class for registration of images/videos
%
% Constructor:
%   obj = Registration(parent, data)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data
        registrationParameters              % aod.core.Parameters
    end

    methods
        function obj = Registration(parent, data)
            obj.allowableParentTypes = {'aod.core.Epoch', 'aod.core.Empty'};
            if nargin > 0 && ~isempty(parent)
                obj.setParent(parent);
            end
            if nargin > 1
                obj.Data = data;
            end
            obj.registrationParameters = aod.core.Parameters();
        end

        function addParameter(obj, varargin)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, value)
            %   obj.addParamter(paramName, value, paramName, value)
            % -------------------------------------------------------------
            for i = 1:(nargin - 1)
                obj.setParameter(varargin{(2*i)-1}) = varargin{2*i};
            end
        end
    end
end