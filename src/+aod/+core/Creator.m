classdef (Abstract) Creator < handle 
% CREATOR
%
% Description:
%   Class with SetAccess to aod.core.Entity objects containing custom code
%   to populate Experiment, Epoch, etc 
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Experiment
    end

    methods
        function obj = Creator(experiment)
            assert(isSubclass(experiment, 'aod.core.Experiment'),...
                'Input must be subclass of aod.core.Experiment');
            obj.Experiment = experiment;
        end
    end
end