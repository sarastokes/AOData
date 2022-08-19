classdef TreeNodeTypes

    properties (Hidden, Constant)
        ICON_DIR = [fileparts(fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))))),...
            filesep, 'resources', filesep];
    end

    enumeration 

        SCALAR          % Scalar value
        TEXT
        XYSERIES        % First column is the x-axis
        TIMESERIES      % Contains metadata about timing

        TABLE

        IMAGE    
        MASK
        VIDEO
        EXTERNALFILE

        GROUP
        GENERIC 
        UNKNOWN
    end

    methods 

        function tf = isText(obj)
            switch obj 
                case {aod.app.TreeNodeTypes.TEXT, aod.app.TreeNodeTypes.EXTERNALFILE}
                    tf = true;
                otherwise
                    tf = false;
            end
        end

        function tf = isTable(obj)
            switch obj
                case aod.app.TreeNodeTypes.TABLE
                    tf = true;
                otherwise
                    tf = false;
            end
        end

        function tf = autoDeref(obj)
            if obj == aod.app.TreeNodeTypes.VIDEO
                tf = false;
            else
                tf = true;
            end
        end

        function setIcon(obj, node)
            import aod.app.TreeNodeTypes 
            switch obj
                case {TreeNodeTypes.IMAGE, TreeNodeTypes.MASK} 
                    iconPath = [obj.ICON_DIR, 'image.png'];
                case TreeNodeTypes.TEXT
                    iconPath = [obj.ICON_DIR, 'text.png'];
                case TreeNodeTypes.GROUP 
                    iconPath = [obj.ICON_DIR, 'folder.png'];
                otherwise 
                    iconPath = [obj.ICON_DIR, 'spreadsheet.png'];
            end
            node.Icon = iconPath;
        end

        function show(obj, dataObj, parentHandle)
            if isempty(dataObj)
                return;
            end

            if obj.autoDeref
                data = dataObj.data;
            else
                return;
            end

            import aod.app.TreeNodeTypes

            switch obj
                case TreeNodeTypes.TIMESERIES
                    parentHandle.NextPlot = 'add';
                    for i = 1:size(data, 2)
                        line(parentHandle, 1:size(data,1), data(:, i), 'LineWidth', 2);
                    end
                    xlim(parentHandle, [0, size(data,1)]);
                    hold(parentHandle, 'off');
                case TreeNodeTypes.XYSERIES 
                    hold(parentHandle, 'on');
                    for i = 2:size(data, 2)
                        line(parentHandle, data(:, 1), data(:, i), 'LineWidth', 1);
                    end
                    hold(parentHandle, 'off');
                case TreeNodeTypes.IMAGE 
                    imagesc(data, 'Parent', parentHandle);
                    axis(parentHandle, 'equal');
                case TreeNodeTypes.MASK
                    imagesc(data, 'Parent', parentHandle);
                    axis(parentHandle, 'equal', 'tight', 'off');
                case TreeNodeTypes.SCALAR
                    text(0.5, 0.5, num2str(data), 'FontSize', 10);
                case {TreeNodeTypes.TEXT, TreeNodeTypes.EXTERNALFILE}
                    parentHandle.Value = data;
                case TreeNodeTypes.TABLE
                    parentHandle.Data = struct2table(data);
            end
        end
    end

    methods (Static)
        function obj = init(x)
            import aod.app.TreeNodeTypes

            if nargin == 0 || isempty(x)
                obj = TreeNodeTypes.GENERIC;
                return;
            end
            
            switch lower(x)
                case 'group'
                    obj = TreeNodeTypes.GROUP;
                case 'xyseries'
                    obj = TreeNodeTypes.XYSERIES; 
                case 'image'
                    obj = TreeNodeTypes.IMAGE;
                case 'mask'
                    obj = TreeNodeTypes.MASK;
                case 'timeseries'
                    obj = TreeNodeTypes.TIMESERIES;
                case 'text'
                    obj = TreeNodeTypes.TEXT;
                case 'scalar'
                    obj = TreeNodeTypes.SCALAR;
                case 'video'
                    obj = TreeNodeTypes.VIDEO;
                case 'externalfile'
                    obj = TreeNodeTypes.EXTERNALFILE;
                case 'table'
                    obj = TreeNodeTypes.TABLE;
                otherwise
                    warning('TreeNODETYPES:Unknown node type %s', x);
                    obj = TreeNodeTypes.UNKNOWN;
            end
        end
    end
end