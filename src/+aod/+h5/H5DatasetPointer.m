classdef H5DatasetPointer < handle
% H5DATASETPOINTER
%
% Description:
%   Holds reference to the HDF dataset without automatically loading data 
%
% Constructor:
%   obj = H5DatasetPointer(fileName, datasetPath)
% -------------------------------------------------------------------------
   
    properties (SetAccess = private)
        fileName
        datasetPath
    end

    properties (Hidden, Dependent)
        data
    end

    properties (Access = private)
        dataset
    end

    methods
        function obj = H5DatasetPointer(fileName, datasetPath)
            obj.fileName = fileName;
            obj.datasetPath = datasetPath;
            obj.dataset = [];
        end

        function data = get.data(obj)
            if isempty(obj.dataset)
                obj.deref();
            end
            data = obj.dataset;
        end

        function deref(obj)
            obj.dataset = h5read(obj.fileName, obj.datasetPath);
        end

        function tf = didDeref(obj)
            if isempty(obj.dataset)
                tf = false;
            else
                tf = true;
            end
        end
    end
end