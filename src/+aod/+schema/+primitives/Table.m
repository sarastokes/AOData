classdef Table < aod.schema.primitives.Container
% TABLE
%
% Description:
%   A dataset with multiple distinct data objects that differ in their
%   primitive types, validation or metadata (decorators like description).
%   Unlike Object, Table includes a size restriction such that each item
%   must have the same number of elements.
%
% Constructor:
%   obj = aod.schema.primitives.Table(name, parent, varargin)
%
% TODO: If timetable, first item must be duration

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        RowNames                aod.schema.validators.RowNames
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.TABLE
        OPTIONS = ["Class", "Size", "Items", "Default", "Description"]
        VALIDATORS = ["Class", "Size"]
    end

    methods
        function obj = Table(parent, varargin)
            obj = obj@aod.schema.primitives.Container(parent);

            % Initialization
            obj.RowNames = aod.schema.validators.RowNames(obj, []);

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            if ~obj.Class.isSpecified()
                obj.setClass("table");
            end
            obj.isInitializing = false;
            obj.checkIntegrity(true);
            obj.assignDefault();
        end
    end

    methods
        function setClass(obj, value)
            arguments
                obj
                value       string
            end

            if ~aod.util.isempty(value)
                mustBeMember(value, ["table", "timetable"]);
            end

            setClass@aod.schema.primitives.Container(obj, value);
        end

        function setDefault(obj, value)
            if isempty(value)
                if istable(value) && ~isempty(value.Properties.VariableNames)
                    obj.Default.setValue(value);
                else
                    return
                end
            end

            obj.validate(value, aod.infra.ErrorTypes.ERROR);
            obj.Default.setValue(value);
        end

        function setRowNames(obj, value)
            arguments
                obj
                value           string
            end

            if aod.util.isempty(value)
                obj.RowNames.setValue([]);
            end

            obj.assignDefault();
            obj.checkIntegrity(true);
        end
    end

    methods (Access = private)
        function assignDefault(obj)
            if obj.Default.isSpecified() || obj.numItems == 0
                return
            end

            % Create an empty table matching specs
            T = array2table(zeros(0, obj.numItems),...
                'VariableNames', cellstr(obj.Collection.getNames()));
            if obj.RowNames.isSpecified()
                T.RowNames = obj.rowNames.Value;
            end
            obj.Default.setValue(T);
        end
    end

    % Container methods
    methods
        function addItem(obj, newItem)
            addItem@aod.schema.primitives.Container(obj, newItem);

            % Ensure size reflects current number of items and preserve
            % the number of rows if it was specified.
            if ~obj.Size.isSpecified()
                % Set the Size specification (usually when adding item 1)
                obj.setSize(sprintf("(:,%u)", obj.numItems));
            else
                firstDim = extractBetween(obj.Size.text(), "(", ",");
                obj.setSize(sprintf("(%s,%u)", firstDim, obj.numItems))
                obj.Size.Value(2).setValue(obj.numItems);
            end
            obj.assignDefault();
        end

        function removeItem(obj, ID)
            removeItem@aod.schema.primitives.Container(obj, ID);

            % Ensure size reflects current number of items and preserve
            % the number of rows if it was specified.
            firstDim = extractBetween(obj.Size.text(), "(", ",");
            if obj.numItems == 0
                obj.setSize('(:,:)');
            else
                obj.setSize(sprintf("(%s, %u)", firstDim, obj.numItems))
            end
            obj.assignDefault();
        end
    end

    % Primitive methods
    methods
        function [tf, ME, excObj] = checkIntegrity(obj, throwError)
            arguments
                obj
                throwError          logical = false
            end

            if obj.isInitializing
                return
            end

            [~, ~, excObj] = checkIntegrity@aod.schema.primitives.Container(obj);
            if obj.Class == "timetable" && obj.numItems > 0
                if obj.Items(1).primitiveType ~= aod.schema.primitives.PrimitiveType.DURATION
                    excObj.addCause(MException("checkIntegrity:FirstItemMustBeDuration",...
                        "Class is timetable but first item is %s, not duration.",...
                        string(obj.Items(1).primitiveType)));
                end
            end

            if obj.RowNames.isSpecified()
                % TODO
            end

            tf = ~excObj.hasErrors;
            ME = excObj.getException();
            if ~tf && throwError
                throw(ME);
            end
        end

        function [tf, ME] = validate(obj, input, errorType)
            [~, ~, excObj] = validate@aod.schema.primitives.Container(obj, input, errorType);
            if obj.rowNames.isSpecified()
                if height(input) ~= numel(obj.rowNames)
                    excObj.addCause(MException("Table:validate:InvalidHeight"),...
                        'The height (%u) does not match the number of rows (%u)',...
                        height(input), numel(obj.rowNames.Value));
                end
            end
            tf = ~excObj.hasErrors;
            ME = excObj.getException();
        end
    end
end