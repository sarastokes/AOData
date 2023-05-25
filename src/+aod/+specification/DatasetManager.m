classdef DatasetManager < handle
% Organizes the dataset specifications for an AOData core class
%
% Constructor:
%   obj = aod.specification.DatasetManager(className)
%
% Static constructor to populate from metaclass information:
%   obj = aod.specification.DatasetManager.populate(className)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        className       (1,1)   string 
        Datasets 
    end

    properties (Dependent)
        numDatasets 
    end

    methods 
        function obj = DatasetManager(className)
            
            if nargin > 0
                obj.className = convertCharsToStrings(className);
            end
        end
    end

    % Dependent methods
    methods
        function value = get.numDatasets(obj)
            value = numel(obj.Datasets);
        end
    end

    methods
        function set(obj, dsetName, varargin)
            dset = obj.get(dsetName);
            if isempty(dset)
                error('set:DatasetNameNotFound',...
                    'DatasetManager for %s does not have dataset %s', ...
                    obj.className, dsetName);
            end
            
            dset.assign(varargin{:});
        end

        function [tf, idx] = has(obj, dsetName)
            % Determine whether DatasetManager has a dataset
            % -------------------------------------------------------------
            arguments
                obj
                dsetName        string
            end

            if obj.numDatasets == 0
                tf = false; idx = [];
                return
            end
            allNames = obj.list();
            idx = find(allNames == dsetName);
            tf = ~isempty(idx);
        end

        function d = get(obj, dsetName)
            % Get a dataset by name
            % -------------------------------------------------------------
            [tf, idx] = obj.has(dsetName);

            if tf
                d = obj.Datasets(idx);
            else
                d = [];
            end
        end

        function add(obj, dset)
            % Add a new dataset
            %
            % Syntax:
            %   add(obj, dset)
            %
            % Inputs:
            %   dset            aod.specification.Dataset
            %
            % See also:
            %   aod.specification.Dataset
            % -------------------------------------------------------------
            arguments 
                obj
                dset            aod.specification.Dataset 
            end

            if obj.numDatasets > 0 && ismember(dset.Name, obj.list())
                error('add:DatasetExists',...
                    'A dataset named %s is already present', dset.Name);
            end
            obj.Datasets = cat(1, obj.Datasets, dset);
        end

        function names = list(obj)
            % List all dataset names
            %
            % Syntax:
            %   names = list(obj)
            % -------------------------------------------------------------
            if obj.numDatasets == 0
                names = [];
                return 
            end
        
            names = arrayfun(@(x) x.Name, obj.Datasets);
        end

        function out = text(obj)
            % Convert contents to text for display
            %
            % Syntax:
            %   out = text(obj)
            % -------------------------------------------------------------
            if isempty(obj)
                out = "Empty DatasetManager";
                return 
            end

            out = "";
            for i = 1:obj.numDatasets 
                out = out + obj.Datasets(i).text();
            end
        end
    end

    methods (Static)
        function obj = populate(className)
            % Populate and create a DatasetManager from a class name
            %
            % Syntax:
            %   obj = aod.specification.DatasetManager.populate(className)
            %
            % Inputs:
            %   className           string/char, meta.class, object
            %       Class (must be aod.core.Entity subclass)
            %
            % Examples:
            %   obj = aod.specification.DatasetManager.populate('aod.core.Epoch')
            % -------------------------------------------------------------
            
            if ~isSubclass(className, "aod.core.Entity")
                if isa(className, 'meta.class')
                    className = className.Name;
                end
                error('populate:InvalidInput',...
                    'Class %s is not a subclass of aod.core.Entity', className);
            end

            if istext(className)
                mc = meta.class.fromName(className);
            elseif isa(className, 'meta.class')
                mc = className;
            elseif isobject(className)
                mc = metaclass(className);
            else
                error('populate:InvalidInput',...
                    'Input must be class name or meta.class, not %s', ...
                    class(className));
            end

            propList = mc.PropertyList;
            classProps = aod.h5.getPersistedProperties(mc.Name);
            systemProps = aod.infra.getSystemProperties();

            obj = aod.specification.DatasetManager(mc.Name);
            for i = 1:numel(propList)
                % Skip system properties
                if ismember(propList(i).Name, systemProps)
                    continue
                end

                % Skip properties that will not be persisted
                if ~ismember(propList(i).Name, classProps)
                    continue
                end

                dataObj = aod.specification.Dataset(propList(i));
                obj.add(dataObj);
            end
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isempty(obj)
            tf = (obj.numDatasets == 0);
        end

        function S = struct(obj)
            % Convert specified datasets to a structure
            %
            % Syntax:
            %   S = struct(obj)
            % -------------------------------------------------------------
            S = struct();
            if isempty(obj)
                return
            end

            for i = 1:obj.numDatasets
                iStruct = obj.Datasets(i).struct();
                % Place into a struct named for the dataset
                S.(obj.Datasets(i).Name) = iStruct;
            end
        end

        function T = table(obj)
            % Create a table from dataset specifications
            %
            % Syntax:
            %   T = table(obj)
            %
            % Output:
            %   T           table
            %       Table where each row is a dataset
            % -------------------------------------------------------------
            if isempty(obj)
                T = table.empty();
                return 
            end

            names = arrayfun(@(x) x.Name, obj.Datasets);
            descriptions = arrayfun(@(x) x.Description.text(), obj.Datasets);
            sizes = arrayfun(@(x) x.Size.text(), obj.Datasets);
            classes = arrayfun(@(x) x.Class.text(), obj.Datasets);
            defaults = arrayfun(@(x) x.Default.text(), obj.Datasets);
            functions = arrayfun(@(x) x.Functions.text(), obj.Datasets);

            T = table(names, descriptions, classes, sizes, functions, defaults,...
                'VariableNames', {'Name', 'Description', 'Class', 'Size', 'Functions', 'Default'});
        end
    end
end 