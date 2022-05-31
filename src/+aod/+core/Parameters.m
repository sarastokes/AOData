classdef Parameters < containers.Map & handle 
% PARAMETERS
%
% Description:
%   Wrapper for containers.Map with extra functions
%
% Constructor:
%   obj = aod.core.Parameters(keySet, valueSet)
%   obj = aod.core.Parameters('KeyType', kType, 'ValueType', vType)
% 
% Methods:
%   list(obj)
%
% See also:
%   containers.Map
% -------------------------------------------------------------------------
    methods
        function obj = Parameters(varargin)
            obj = obj@containers.Map(varargin{:});
        end

        function list(obj)
            % LIST
            % 
            % Syntax:
            %   list(obj)
            % -------------------------------------------------------------
            if isempty(obj)
                fprintf('\tParameters is empty\n');
                return
            end

            k = obj.keys;
            for i = 1:numel(k)
                fprintf('\t%s = ', k{i});
                disp(obj(k{i}));
            end
        end
    end
end 