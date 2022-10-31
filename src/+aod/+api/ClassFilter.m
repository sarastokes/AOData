classdef ClassFilter < aod.api.FilterQuery 

    properties (SetAccess = private)
        className
    end
    
    properties (Access = protected)
        allClassNames
    end

    methods
        function obj = ClassFilter(hdfName, className)
            obj = obj@aod.api.FilterQuery(hdfName);
            obj.className = className;

            obj.collectClassNames();
            obj.applyFilter();
        end

        function applyFilter(obj)
            for i = 1:numel(obj.allClassNames)
                if obj.filterIdx(i)
                    obj.filterIdx(i) = strcmpi(obj.className, obj.allClassNames(i));
                end
            end
        end
    end

    methods (Access = private)
        function collectClassNames(obj)
            classNames = repmat("", [numel(obj.allGroupNames), 1]);
            for i = 1:numel(obj.groupNames)
                classNames(i) = h5readatt(obj.hdfName,...
                    obj.allGroupNames(i), 'Class');
            end
        end
    end
end 