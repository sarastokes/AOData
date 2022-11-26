classdef FilterTypes

    enumeration
        ENTITY
        PARAMETER
        DATASET
        LINK

        % Convenience subclasses of the above filters
        CLASS
        NAME
        PARENT
    end

    methods
        function out = getFcn(obj)
            import aod.api.FilterTypes

            switch obj
                case FilterTypes.ENTITY
                    out = str2func('aod.api.EntityFitler');
                case FilterTypes.PARAMETER
                    out = str2func('aod.api.ParameterFilter');
                case FilterTypes.DATASET
                    out = str2func('aod.api.DatasetFilter');
                case FilterTypes.LINK
                    out = str2func('aod.api.LinkFilter');
                case FilterTypes.CLASS
                    out = str2func('aod.api.ClassFilter');
                case FilterTypes.NAME
                    out = str2func('aod.api.NameFilter');
            end
        end
    end
    
    methods (Static)
        function out = get(filterType, varargin)

            obj = aod.api.FilterTypes.init(filterType);

            if nargin > 1
                fcn = obj.getFcn();
                out = fcn(varargin{:});
            else
                out = obj;
            end
        end

        function obj = init(filterType)
            import aod.api.FilterTypes

            switch lower(filterType)
                case 'entity'
                    obj = FilterTypes.ENTITY;
                case 'parameter'
                    obj = FilterTypes.PARAMETER;
                case 'dataset'
                    obj = FilterTypes.DATASET;
                case 'link'
                    obj = FilterTypes.LINK;
                case 'class'
                    obj = FilterTypes.CLASS;
                case 'name'
                    obj = FilterTypes.NAME;
                case 'parent'
                    obj = FilterTypes.PARENT;
                otherwise
                    error("FilterTypes_init:UnknownType",...
                        'FilterType %s not recognized', filterType);
            end
        end
    end
end