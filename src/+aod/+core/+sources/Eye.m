classdef Eye < aod.core.Source 

    properties (SetAccess = private)
        whichEye
    end

    methods
        function obj = Eye(parent, whichEye)
            obj = obj@aod.core.Source(parent);
            obj.whichEye = whichEye;
        end
    end

    methods (Access = protected)    
        function value = getLabel(obj)  
            % LABEL
            %      
            % Syntax:
            %   value = obj.getLabel()
            % -------------------------------------------------------------
            try
                value = [num2str(obj.Parent.label), '_', obj.whichEye];
            catch
                value = obj.whichEye;
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