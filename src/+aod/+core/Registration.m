classdef Registration < aod.core.Entity & matlab.mixin.Heterogeneous
% REGISTRATION
%
% Description:
%   Class for registration of images/videos
%
% Constructor:
%   obj = Registration(parent, data)
%
% Sealed methods:
%   setRegistrationDate(obj, regDate)
%   addParameter(obj, varargin)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data
        registrationDate(1,1)               datetime
        registrationParameters              % aod.core.Parameters
    end

    methods
        function obj = Registration(parent, data)
            obj = obj@aod.core.Entity();
            obj.allowableParentTypes = {'aod.core.Epoch', 'aod.core.Empty'};
            if nargin > 0 && ~isempty(parent)
                obj.setParent(parent);
            end
            if nargin > 1
                obj.Data = data;
            end
            obj.registrationParameters = aod.core.Parameters();
        end

        function varargout = apply(obj, varargin) %#ok<*STOUT,*INUSD> 
            error('Not yet implemented');
        end
    end

    methods (Sealed)
        function setRegistrationDate(obj, regDate)
            % SETREGISTRATIONDATE
            %
            % Description:
            %   Set the date where the registration was performed
            % 
            % Syntax:
            %   obj.setRegistrationDate(regDate)
            % -------------------------------------------------------------
            if ~isdatetime(regDate)
                regDate = datetime(regDate, 'Format', 'YYYYMMDD');
            end
            obj.registrationDate = regDate;
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