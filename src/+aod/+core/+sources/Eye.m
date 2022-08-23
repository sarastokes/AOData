classdef Eye < aod.core.Source 
% EYE
%
% Description:
%   An eye within a Subject
%
% Parent:
%   aod.core.Source
%
% Constructor:
%   obj = Eye(parent, name)
%
% Note:
%   Name is restricted to either 'OD' or 'OS'      
% -------------------------------------------------------------------------

    methods
        function obj = Eye(parent, name)
            assert(ismember(name, {'OD', 'OS'}), 'Eye: Must be OS or OD');
            obj = obj@aod.core.Source(parent, name);
        end
    end

    % Overloaded methods
    methods (Access = protected)    
        function value = getLabel(obj)  
            if ~isempty(obj.Parent)
                value = [obj.Parent.Name, '_', obj.Name];
            else
                value = obj.Name;
            end
        end

        function value = getShortLabel(obj)
            value = obj.Name;
        end
    end
end