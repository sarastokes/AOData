classdef (Abstract) Factory < handle
% FACTORY (Abstract)
%
% Description:
%   Generic parent class for factories
%
% Constructor:
%   obj = aod.util.Factory()
%
% Abstract methods:
%   newObj = create(obj, varargin)
%
% Static methods
%   newObj = get(varargin)
%
% Notes:
%   Implementation goes into create() and get() is an optional static  
%   method for calling create() without instantiating the object first

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods (Abstract)
        newObj = get(obj, varargin)
    end

    methods
        function obj = Factory()
            % Do nothing
        end
    end

    methods (Static)
        function varargout = create(varargin) %#ok<STOUT> 
            % CREATE
            %
            % Description:
            %   Optional static method for calling get() without creating 
            %   the Factory object first. Subclasses should first create 
            %   the object, then run get() and return the new object
            %
            % Syntax:
            %   varargout = create(varargin)
            % ------------------------------------------------------------- 
            error('create:NotImplemented',...
                'Subclasses must implement the create method');
        end
    end
end