classdef (Abstract) Creator < handle 
% CREATOR
%
% Description:
%   Class with SetAccess to aod.core.Entity objects containing custom code
%   to populate Dataset, Epoch, etc 
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        homeDirectory
    end

    methods
        function obj = Creator(homeDirectory, varargin)
            obj.homeDirectory = homeDirectory;
        end
    end
end