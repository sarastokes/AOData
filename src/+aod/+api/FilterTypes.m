classdef FilterTypes

    enumeration
        ENTITY
        CLASS
        NAME
        PARAMETER
        DATASET
    end

    methods
        function out = getFcn(obj)
            import aod.api.FilterTypes

            switch obj
                case FilterTypes.ENTITY
                    out = str2func('aod.api.EntityFitler');
                case FilterTypes.CLASS
                    out = str2func('aod.api.ClassFilter');
                case FilterTypes.NAME
                    out = str2func('aod.api.NameFilter');
                case FilterTypes.PARAMETER
                    out = str2func('aod.api.ParameterFilter');
                case FilterTypes.DATASET
                    out = str2func('aod.api.DatasetFilter');
            end
        end
    end
    
    methods (Static)
        function out = get(filterType, varargin)
            import aod.api.FilterTypes

            switch lower(filterType)
                case 'entity'
                    obj = FilterTypes.ENTITY;
                case 'class'
                    obj = FilterTypes.CLASS;
                case 'parameter'
                    obj = FilterTypes.PARAMETER;
                case 'name'
                    obj = FilterTypes.NAME;
                case 'dataset'
                    obj = FilterTypes.DATASET;
            end

            if nargin > 1
                fcn = obj.getFcn();
                out = fcn(varargin{:});
            else
                out = obj;
            end
        end
    end
end