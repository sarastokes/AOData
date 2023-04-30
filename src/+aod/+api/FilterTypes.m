classdef FilterTypes
% Enumeration for AOQuery entity filters

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    enumeration
        ENTITY
        PARAMETER
        DATASET
        LINK
        CLASS
        NAME
        PARENT
        CHILD
        UUID 
        PATH 
    end

    methods
        function out = getFcn(obj)
            import aod.api.FilterTypes

            switch obj
                case FilterTypes.ENTITY
                    out = str2func('aod.api.EntityFilter');
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
                case FilterTypes.PARENT 
                    out = str2func('aod.api.ParentFilter');
                case FilterTypes.CHILD 
                    out = str2func('aod.api.ChildFilter');
                case FilterTypes.UUID 
                    out = str2func('aod.api.UuidFilter');
                case FilterTypes.PATH
                    out = str2func('aod.api.PathFilter');
            end
        end
    end
    
    methods (Static)
        function out = makeNewFilter(QM, filterSpec)
            % Creates a new filter
            obj = aod.api.FilterTypes.init(filterSpec{1});
            fcn = obj.getFcn();
            out = fcn(QM, filterSpec{2:end});
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
                case 'child'
                    obj = FilterTypes.CHILD;
                case 'path'
                    obj = FilterTypes.PATH;
                case 'uuid'
                    obj = FilterTypes.UUID;
                otherwise
                    error("init:UnknownType",...
                        'FilterType %s not recognized', filterType);
            end
        end
    end
end