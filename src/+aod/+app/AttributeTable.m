classdef AttributeTable < handle

    properties
        Table           matlab.ui.control.Table
    end

    properties (Hidden, Constant)
        SYSTEM_STYLE = uistyle('FontColor', [0.4 0.4 0.4]);
        SYSTEM_ATTRIBUTES = ["UUID", "description", "Class", "Format",...
            "EntityType", "label", "ColumnClass"];
    end

    methods
        function obj = AttributeTable(parent, varargin)
            obj.createUi(parent, varargin{:});
        end

        function reset(obj)
            removeStyle(obj.Table);
            obj.Table.Data = [];
        end

        function setData(obj, data)
            if istable(data)
                obj.setTableData(data);
            elseif isstruct(data)
                data = obj.attributes2map(data);
                data = table(data.keys', data.values');
                obj.setTableData(data);
            elseif isa(data, {'containers.Map', 'aod.util.Parameters'})
                data = table(data.keys', data.values');
                obj.setTableData(data);
            end
        end

        function out = table(obj)
            out = obj.Table;
        end

        function setLayout(obj, rowID, colID)
            % SETLAYOUT

            if ~isempty(rowID)
                obj.Table.Layout.Row = rowID;
            end

            if nargin < 3 || isempty(colID)
                obj.Table.Layout.Column = colID;
            end
        end
    end


    methods (Access = private)
        function setTableData(obj, data)
            if nargin < 2 || isempty(data)
                obj.reset();
                return
            end

            obj.Table.Data = data;
            systemAttributes = {'uuid', 'label', 'entitytype', 'class', 'format', 'columnclass'};
            rowIdx = find(cellfun(@(x) ismember(lower(x), systemAttributes), data{:, 1}));
            addStyle(obj.Table, obj.SYSTEM_STYLE, 'Row', rowIdx);
        end

        function createUi(obj, parent, varargin)
            obj.Table = uitable(parent, 'FontSize', 12, varargin{:});
            if isempty(obj.Table.ColumnName)
                obj.Table.ColumnName = {'Attribute', 'Value'};
            end
        end

    end

    methods (Static)
        function S = attributes2map(attributes)
            S = containers.Map();
            for i = 1:numel(attributes)
                value = attributes(i).Value;
                if isnumeric(value)
                    value = num2str(value);
                elseif iscell(value) && numel(value) == 1
                    value = value{:};
                end
                S(attributes(i).Name) = value;
            end
        end
    end
end