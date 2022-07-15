classdef (Abstract) Factory < handle
% FACTORY
%
% Description:
%   Generic parent class for factories
%
% Abstract methods:
%   newObj = create(obj, varargin)
%
% Constructor:
%   obj = Factory()
% -------------------------------------------------------------------------

    methods (Abstract)
        newObj = create(obj, varargin)
    end

    methods
        function obj = Factory()
            % Do nothing
        end
    end
end