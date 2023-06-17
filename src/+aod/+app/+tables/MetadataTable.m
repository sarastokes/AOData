classdef MetadataTable < handle 

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        Expt 
        Entities
        ClassName 
        EntityType
    end 

    properties
        Figure 
        classListBox
        Table
    end

    methods
        function obj = MetadataTable(expt, className)
            obj.Expt = expt;
            if nargin > 1
                obj.ClassName = className;
            end
            obj.createUi();
        end
    end

    methods (Access = private)
        function createUi(obj)
            
            obj.Figure = uifigure("Name", "MetadataTable", ...
                "Color", lighten(hex2rgb('bfd3f8'),0.6));
            layout = uigridlayout(obj.Figure, [2 2], ...
                'RowHeight', {30, '1x'}, 'ColumnWidth', {'fit', '1x'},...
                "BackgroundColor", lighten(hex2rgb('bfd3f8'), 0.6));

            T = obj.Expt.factory.entityManager.Table;
            [~, idx] = unique(T.Class);
            T = sortrows(T(idx, :), 'Path');

            uilabel(layout, "Text", "Classes: ",...
                "BackgroundColor", lighten(hex2rgb('bfd3f8'), 0.6),...
                'FontWeight', 'bold');
            
            obj.classListBox = uidropdown(layout,...
                "BackgroundColor", "w",...
                "Editable", "off",...
                'Items', [""; T.Class],...
                'ItemsData', [""; T.Class+"_"+T.Entity],...
                'ValueChangedFcn', @obj.onChanged_Class);
            obj.classListBox.Layout.Row = 1; obj.classListBox.Layout.Column = 2;

            obj.Table = uitable(layout,...
                "Multiselect", "on",...
                'CellEditCallback', @obj.onEdited_Cell);
            obj.Table.Layout.Row = 2; obj.Table.Layout.Column = [1 2];
        end

        function onEdited_Cell(obj, ~, evt)
            if isequal(evt.NewData, evt.PreviousData)
                return
            end
            if isSubclass(obj.Expt, 'aod.persistent.Entity')
                obj.Expt.setReadOnlyMode(false);
            end
            setAttr(obj.Entities(evt.Indices(1)), ...
                obj.Table.ColumnName{evt.Indices(2)}, ...
                evt.NewData);
        end

        function onChanged_Class(obj, ~, evt)

            % Reset the table
            obj.Table.Data=[];
            obj.Table.ColumnName = "numbered";
            removeStyle(obj.Table);

            if evt.Value == ""
                obj.Entities = [];
                return
            end

            txt = strsplit(evt.Value, '_');
            obj.ClassName = txt{1};
            obj.EntityType = txt{2};

            obj.Entities = obj.Expt.get(obj.EntityType, {'Class', obj.ClassName});

            adhocNames = [];
            for i = 1:numel(obj.Entities)
                newNames = obj.getAdhocParameters(obj.Entities(i));
                if ~isempty(newNames)
                    adhocNames = cat(1, adhocNames, newNames);
                end
            end
            allParams = ["Name"; "Parent"; obj.Entities(1).expectedAttributes.list()];
            if ~isempty(adhocNames)
                allParams = [allParams; adhocNames];
            end
            obj.Table.ColumnName = allParams;

            if obj.EntityType == "Experiment"
                parentNames = repmat("[]", [numel(obj.Entities), 1]);
            else
                parentNames = arrayfun(@(x) string(x.Parent.groupName), obj.Entities);
            end

            obj.Table.Data = table(...
                arrayfun(@(x) string(x.groupName), obj.Entities),... 
                parentNames);
            obj.Table.ColumnEditable = false(1, numel(allParams));

            if numel(allParams) == 2
                return
            end

            for i = 3:numel(allParams)
                try
                    obj.Table.Data.(allParams(i)) = getAttr(obj.Entities, ...
                        allParams(i), aod.infra.ErrorTypes.MISSING);
                catch ME 
                    if strcmp(ME.identifier, "getAttr:NotFound")
                        obj.Table.Data.(allParams(i)) = repmat(missing, [numel(obj.Entities), 1]);
                    else
                        rethrow(ME);
                    end
                end
            end

            styleIndices = ismissing(obj.Table.Data);
            if any(styleIndices)
                [row, col] = find(styleIndices);
                addStyle(obj.Table,... 
                    uistyle('BackgroundColor', [1 0.75 0.75]),...
                    "cell", [row, col]);
            end
            if ~isempty(adhocNames)
                numCols = size(obj.Table.Data, 2);
                addStyle(obj.Table, uistyle('FontAngle', 'italic'),...
                    "column", (numCols-numel(adhocNames)+1):numCols);
            end
            obj.Table.ColumnEditable(3:end) = true;
        end
    end

    methods (Static)
        function adhocNames = getAdhocParameters(entity)
            attrNames = entity.attributes.keys;
            expectedNames = entity.expectedAttributes.list();
            adhocNames = setdiff(attrNames, expectedNames);
        end
    end
end 