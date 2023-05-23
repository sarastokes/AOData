classdef SpecificationManager < handle 

    properties (SetAccess = private)
        Datasets 
    end

    properties (Dependent)
        numDatasets 
    end

    methods 
        function obj = SpecificationManager()
        end
    end

    % Dependent methods
    methods
        function value = get.numDatasets(obj)
            value = numel(obj.Datasets);
        end
    end

    methods 
        function addDataset(obj, dset)
            arguments 
                obj
                dset        aod.specification.DataObject 
            end

            if ~isscalar(dset)
                dset = dset';
            end

            obj.Datasets = cat(1, obj.Datasets, dset);
        end

        function names = listDatasets(obj)
            if obj.numDatasets == 0
                names = [];
                return 
            end
        
            names = arrayfun(@(x) x.Name, obj.Datasets);
        end

        function [tf, idx] = hasDataset(obj, dsetName)
            arguments 
                obj 
                dsetName        string 
            end

            if obj.numDatasets == 0
                tf = false; idx = [];
                return 
            end

            allNames = obj.listDatasets();
            idx = find(allNames == dsetName);
            tf = ~isempty(idx);
        end

        function d = get(obj, dsetName)
            [tf, idx] = obj.hasDataset(dsetName);
            if tf 
                d = obj.Datasets(idx);
            else
                d = [];
            end
        end

        function out = text(obj)
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
            
            mc = meta.class.fromName(className);
            propList = mc.PropertyList;
            classProps = aod.h5.getPersistedProperties(mc);
            systemProps = aod.infra.getSystemProperties();

            obj = aod.specification.SpecificationManager();
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
                obj.addDataset(dataObj);
            end
        end
    end
end 