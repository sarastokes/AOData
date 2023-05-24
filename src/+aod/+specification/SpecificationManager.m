classdef SpecificationManager < handle 

    properties (SetAccess = private)
        className       (1,1)   string 
        Datasets 
    end

    properties (Dependent)
        numDatasets 
    end

    methods 
        function obj = SpecificationManager(className)
            
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
                    'SpecificationManager for %s does not have dataset %s',...
                    obj.className, dsetName);
            end
            
            dset.assign(dsetName, varargin{:});
        end

        function [tf, idx] = has(obj, dsetName)
            % Determine whether SpecificationManager has a dataset
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
            % -------------------------------------------------------------
            arguments 
                obj
                dset            aod.specification.DataObject 
            end

            if ~isscalar(dset)
                arrayfun(@(x) obj.add(x), dset);
                return 
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
                out = "Empty Specification Manager";
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
            % Populate and create a SpecificationManager from a class name
            %
            % Syntax:
            %   obj = aod.specification.SpecificationManager.populate(className)
            %
            % Inputs:
            %   className           string or char
            %       Name of class (must be aod.core.Entity subclass)
            %
            % Examples:
            %   obj = aod.specification.SpecificationManager.populate('aod.core.Epoch')
            % -------------------------------------------------------------
            
            if ~isSubclass(className, "aod.core.Entity")
                error('populate:InvalidInput',...
                    'Class %s is not a subclass of aod.core.Entity', className);
            end

            mc = meta.class.fromName(className);

            propList = mc.PropertyList;
            classProps = aod.h5.getPersistedProperties(mc);
            systemProps = aod.infra.getSystemProperties();

            obj = aod.specification.SpecificationManager(className);
            for i = 1:numel(propList)
                % Skip system properties
                if ismember(propList(i).Name, systemProps)
                    continue
                end

                % Skip properties that will not be persisted
                if ~ismember(propList(i).Name, classProps)
                    continue
                end

                dataObj = aod.specification.DataObject(propList(i));
                obj.add(dataObj);
            end
        end
    end

    % MATLAB builtin methods
    methods
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
            functions = arrayfun(@(x) x.Functions.text(), obj.Datasets);

            T = table(names, descriptions, classes, sizes, functions,...
                'VariableNames', {'Name', 'Description', 'Class', 'Size', 'Functions'});
        end
    end
end 