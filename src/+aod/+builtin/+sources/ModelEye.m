classdef ModelEye < aod.core.Source 
% A Model Eye
%
% Parent:
%   aod.core.Source
%
% Constructor:
%   obj = ModelEye()
%   obj = ModelEye(name, varargin)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    methods
        function obj = ModelEye(name, varargin)
            if nargin < 1 || isempty(name)
                name = 'ModelEye';
            end

            obj@aod.core.Source(name, varargin{:});
        end
    end
end 