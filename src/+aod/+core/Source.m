classdef (Abstract) Source < aod.core.Entity 
% SOURCE
%
% Description:
%   A class for the data's source
%
% Properties:
%   sourceParameters                aod.core.Parameters
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        sourceParameters            % aod.core.Parameters
    end

    methods
        function obj = Source(parent)
            obj.allowableParentTypes = {'aod.core.Dataset',...
                'aod.core.Source', 'aod.core.Subject', 'aod.core.Empty'};
            % Check if a parent input was supplied
            if nargin > 0 && ~isempty(parent)
                obj.setParent(parent);
            end
            obj.sourceParameters = aod.core.Parameters();
        end
    end

    methods
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
                    obj.sourceParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.sourceParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
        end
    end
end