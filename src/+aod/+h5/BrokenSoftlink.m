classdef BrokenSoftlink < handle
% Prevents error when reading broken link and lets user fix 
% 
% Constructor:
%   obj = aod.h5.BrokenSoftlink(entity, linkName, target)
%
% See also:
%   aod.h5.replaceLink, aod.persistent.Entity

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Parent              
        Name                string
        Target              string
    end

    methods 
        function obj = BrokenSoftlink(entity, name, target)
            assert(isSubclass(entity, 'aod.persistent.Entity'),...
                'Entity must be part of the persistent interface');
            obj.Parent = entity;
            obj.Name = name;
            obj.Target = target;
        end

        function fixLink(obj, newTarget)
            % Fix the softlink
            %
            % Syntax:
            %   obj.fixLink(newTarget)
            %
            % Inputs:
            %   newTarget           char or aod.persistent.Entity subclass
            %       The link destination, hdf path or entity
            % ----------------------------------------------------------

            obj.Parent.addDataset(obj.Name, newTarget);
        end
    end
end