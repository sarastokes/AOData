classdef BrokenSoftlink < handle
% Prevents error when reading broken link and lets user fix 
% 
% Constructor:
%   obj = aod.h5.BrokenSoftlink(hdfFile, hdfPath, target)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------


    properties
        Parent              
        Name                string
        Target              string
    end

    methods 
        function obj = BrokenSoftlink(entity, name, target)
            obj.Parent = entity;
            obj.Name = name;
            obj.Target = target;
        end

        function fixLink(obj, newPath)
            % Fix the softlink
            
        end
    end
end