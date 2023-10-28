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

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.TABLE
        OPTIONS = ["Class", "Size", "Items", "Default", "Description"];
        VALIDATORS = ["Class", "Size"]
    end

    methods
        function obj = Table(name, parent, varargin)
            obj = obj@aod.schema.primitives.Container(name, parent);

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function setClass(obj, value)
            arguments
                obj
                value       {mustBeMember(value, ["table", "timetable"])}
            end

            obj.setClass(value);
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
        end
    end

    % Primitive methods
    methods
        function [tf, ME] = checkIntegrity(obj, throwError)
            arguments
                obj
                throwError          logical = false
            end

            if obj.isInitializing
                return
            end

            [tf, ME, excObj] = checkIntegrity@aod.schema.primitives.Container(obj);
            if obj.Class == "timetable" && obj.numItems > 0
                if obj.Items(1).primitiveType ~= aod.schema.primitives.PrimitiveType.DURATION
                    excObj.addCause(MException("checkIntegrity:FirstItemMustBeDuration",...
                        "Class is timetable but first item is %s, not duration.",...
                        string(obj.Items(1).primitiveType)));
                end
            end

            tf = excObj.isValid;
            ME = excObj.getException();
            if ~tf && throwError
                throw(ME);
            end
        end
    end
end