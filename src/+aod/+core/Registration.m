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
            %   obj.addParameter(paramName, value, paramName, value)
            %   obj.addParameter(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    obj.registrationParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.registrationParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
        end
    end
end