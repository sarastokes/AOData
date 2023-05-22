classdef DatasetManager < handle & matlab.mixin.CustomDisplay
% Expected Dataset manager
%
% Constructor:
%   obj = aod.util.DatasetManager()
%
% Properties:
%   ExpectedDatasets            aod.util.templates.ExpectedDataset
%
% Dependent Properties:
%   Count
%
% See also:
%   aod.util.templates.ExpectedDataset, aod.util.AttributeManager

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ExpectedDatasets        % aod.util.templates.ExpectedDataset
    end

    properties (Dependent)
        Count
    end

    methods
        function obj = DatasetManager()
        end

        function value = get.Count(obj)
            if isempty(obj.ExpectedDatasets)
                value = 0;
            else
                value = numel(obj.ExpectedDatasets);
            end
        end
    end

    methods 
        function p = get(obj, dsetName)
            % Get an ExpectedDataset, if it exists
            %
            % Syntax:
            %   p = get(obj, dsetName)
            % -------------------------------------------------------------

            [tf, idx] = obj.hasDataset(dsetName);
            if tf 
                p = obj.ExpectedDatasets(idx);
            else
                p = [];
            end
        end

        function add(obj, name, className, defaultValue, validator, description, units)
            % Add a dataset
            %
            % Syntax:
            %   add(obj, name, class, default, validator, description, units)
            % -------------------------------------------------------------
            
            arguments
                obj
                name    
                className                   = []
                defaultValue                = []
                validator                   = {}
                description     string      = ""
                units           string      = ""
            end

            if isa(name, 'aod.util.templates.ExpectedDataset')
                for i = 1:numel(name)
                    [datasetExists, idx] = obj.hasDataset(name(i).Name);
                    if datasetExists
                        warning("add:OverwroteDataset",...
                            "Overwriting expected dataset %s", name(i).Name);
                        obj.ExpectedDatasets(idx) = name;
                    else
                        obj.ExpectedDatasets = cat(1, obj.ExpectedDatasets, name(i));
                    end
                end
                return
            end
            ED = aod.util.templates.ExpectedDataset(name, className,... 
                defaultValue, validator, description, units);

            [datasetExists, idx] = obj.hasDataset(name);
            if datasetExists 
                warning("add:OverwroteDataset",...
                    "Overwriting expected dataset %s", name);
                obj.ExpectedDatasets(idx) = ED;
            else
                obj.ExpectedDatasets = cat(1, obj.ExpectedDatasets, ED);
            end
        end

        function remove(obj, name)
            % Remove a dataset by name
            %
            % Syntax:
            %   remove(obj, name)
            % ----------------------------------------------------------

            if isempty(obj.ExpectedDatasets)
                return
            end

            idx = find(name == obj.list());

            if isempty(idx)
                warning('remove:DatasetNotFound',... 
                    'Dataset %s not found', name);
            else
                obj.ExpectedDatasets(idx) = [];
            end
        end

        function clear(obj)
            % Clear all datasets
            %
            % Syntax:
            %   clear(obj)
            % ----------------------------------------------------------

            obj.ExpectedDatasets = [];
        end
    end

    methods
        function names = list(obj)
            % List the names of all expected datasets
            %
            % Syntax:
            %   names = list(obj)
            % ----------------------------------------------------------
            if isempty(obj)
                names = [];
                return
            end

            names = arrayfun(@(x) x.Name, obj.ExpectedDatasets);
        end

        function [tf, idx] = hasDataset(obj, name)
            % Check whether dataset exists and optionally get index
            %
            % Syntax:
            %   [tf, idx] = hasDataset(obj, name)
            % ----------------------------------------------------------
            if isempty(obj.ExpectedDatasets)
                tf = false; idx = [];
                return
            end

            name = convertCharsToStrings(name);
            allDatasetNames = arrayfun(@(x) string(x.Name), obj.ExpectedDatasets);
            idx = find(allDatasetNames == name);
            tf = ~isempty(idx);
        end
    end

    % matlab.mixin.CustomDisplay
    methods (Access = protected)
        function header = getHeader(obj)
            if isempty(obj)
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            else
                headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                headerStr = sprintf('%s with %u parameters:',...
                    headerStr, numel(obj.ExpectedDatasets));
                header = sprintf('  %s', headerStr);
            end
        end

        function propgrp = getPropertyGroups(obj)
            if isempty(obj)
                propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                propList = struct();

                for i = 1:numel(obj.ExpectedDatasets)
                    value = "";
                    if isempty(obj.ExpectedDatasets(i).Class)                        
                        value = value + "[]";
                    else
                        value = value + strtrim(formattedDisplayText(obj.ExpectedDatasets(i).Class));
                    end

                    value = value + ", ";
                    if isempty(obj.ExpectedDatasets(i).Default)
                        value = value + "[]";
                    else
                        value = value + strtrim(formattedDisplayText(obj.ExpectedDatasets(i).Default));
                    end

                    value = value + ", ";
                    if isempty(obj.ExpectedDatasets(i).Validation)
                        value = value + "[]";
                    else
                        value = value + strtrim(formattedDisplayText(obj.ExpectedDatasets(i).Validation));
                    end

                    value = value + ", ";
                    value = value + strtrim(formattedDisplayText(obj.ExpectedDatasets(i).Description));

                    if ~isempty(obj.ExpectedDatasets(i).Units)
                        value = value + " (units=" + strtrim(formattedDisplayText(...
                            obj.ExpectedDatasets(i).Units)) + ")";
                    end

                    
                    propList.(obj.ExpectedDatasets(i).Name) = value;
                end
                propgrp = matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end

    % Builtin methods
    methods 
        function tf = isempty(obj)
            tf = (obj.Count == 0);
        end

        function T = table(obj)
            if isempty(obj)
                T = [];
                return
            end

            names = repmat("", [obj.Count, 1]);
            classes = names;
            defaults = names;
            validations= names;
            descriptions = names;
            units = names;

            for i = 1:obj.Count 
                ED = obj.ExpectedDatasets(i);

                names(i) = ED.Name;

                if ~isempty(ED.Class)
                    classes(i) = value2string(ED.Class);
                end

                if ~isempty(ED.Default)
                    defaults(i) = value2string(ED.Default);
                end

                if ~isempty(ED.Validation)
                    validations(i) = value2string(ED.Validation);
                end

                if ~isempty(ED.Description)
                    descriptions(i) = ED.Description;
                end

                if ~isempty(ED.Units)
                    units(i) = ED.Units;
                end
            end

            T = table(names, classes, defaults, validations, descriptions, units,...
                'VariableNames', ["Name", "Class", "Default", "Validation", "Description", "Units"]);
        end
    end

    methods (Static)
        function DM = populate(obj)
            
            if istext(obj) && ismember('aod.core.Entity', superclasses(obj))
                mc = meta.class.fromName(obj);
            elseif isSubclass(obj, 'aod.core.Entity')
                mc = metaclass(obj);
            else
                error('populate:InvalidInput',...
                    'Input must be a class or class name with superclass aod.core.Entity');
            end
            
            % mc = metaclass(obj);
            propList = mc.PropertyList;

            % [props, ~, ~, emptyProps] = aod.h5.getPersistedProperties(obj);
            classProps = aod.h5.getPersistedProperties(mc);
            %classProps = [props; emptyProps];
            systemProps = aod.infra.getSystemProperties();

            ED = []; numProps = 0;
            for i = 1:numel(propList)
                % Skip system properties
                if ismember(propList(i).Name, systemProps)
                    continue
                end
                % Skip properties that will not be persisted
                if ~ismember(propList(i).Name, classProps)
                    continue
                end

                if propList(i).HasDefault
                    defaultValue = propList(i).DefaultValue;
                else
                    defaultValue = [];
                end

                if isempty(propList(i).Validation)
                    className = [];
                    validator = [];
                else
                    className = propList(i).Validation.Class;
                    validator = propList(i).Validation.ValidatorFunctions;
                end

                [description, units] = aod.util.DatasetManager.extractUnits(...
                    propList(i).Description);

                iDataset = aod.util.templates.ExpectedDataset(...
                    propList(i).Name, className, defaultValue,...
                    validator, description, units);
                ED = cat(1, ED, iDataset);
                numProps = numProps+1;
            end
            
            DM = aod.util.DatasetManager();
            if ~isempty(propList) && numProps > 0
                DM.add(ED);
            end
        end
        
        function [description, units] = extractUnits(txt)
            description = txt;
            units = [];

            if isempty(txt)
                return
            end

            if endsWith(txt, ")")
                units = extractBetween(txt, "(", ")");
                if ~isempty(units)
                    description = erase(txt, "(" + units + ")");
                end
            end
        end
    end
end 