classdef Eye < aod.core.Source 

    methods
        function obj = Eye(parent, name)
            assert(ismember(name, {'OD', 'OS'}), 'Eye: Must be OS or OD');
            obj = obj@aod.core.Source(parent, name);
        end
    end

    methods (Access = protected)    
        function value = getLabel(obj)  
            % LABEL
            %      
            % Syntax:
            %   value = obj.getLabel()
            % -------------------------------------------------------------
            if ~isempty(obj.Parent)
                value = [obj.Parent.name, '_', obj.name];
            else
                value = obj.name;
            end
        end

        function shortName = getShortName(obj)
            % GETSHORTNAME
            % 
            % Syntax:
            %   shortName = obj.getShortName()
            % -------------------------------------------------------------
            shortName = obj.whichEye;
        end
    end
end