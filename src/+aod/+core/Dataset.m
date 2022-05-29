classdef (Abstract) Dataset < aod.core.Entity
% DATASET
%
% Constructor:
%   obj = Dataset(expDate, source)
%
% Public methods:
%   setHomeDirectory(obj, filePath)
%   id = id2epoch(obj, epochID)
%   idx = id2idx(obj, epochID)
%   imStack = getStacks(obj, epochIDs)
%   data = getRegionResponses(obj, epochIDs)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        homeDirectory           %{mustBeFolder}
        experimentDate(1,1)     datetime
        datasetParameters

        Epochs                  %aod.core.Epoch
        Source                  %aod.core.Source
        Regions                 %aod.core.Regions

        epochIDs                double
    end

    properties (Hidden, SetAccess = private)
        baseDirectory       % File path used to initialize Dataset
    end

    methods (Abstract)
        value = getFileHeader(obj)
    end
    
    methods 
        function obj = Dataset(homeDirectory, expDate)
            obj.datasetParameters = containers.Map();
            if nargin > 0
                obj.setHomeDirectory(homeDirectory);
            end
            if nargin > 1
                obj.experimentDate = datetime(expDate, 'Format', 'yyyyMMdd');
            end
        end

        function setHomeDirectory(obj, filePath)
            % SETHOMEDIRECTORY
            %
            % Description:
            %   Set a new base filepath. Useful if you are analyzing data 
            %   on multiple computers
            %
            % Syntax:
            %   setHomeDirectory(obj, filePath)
            % -------------------------------------------------------------
            assert(isfolder(filePath), 'filePath is not valid!');
            obj.homeDirectory = filePath;
        end
    end

    methods
        function epoch = id2epoch(obj, IDs)
            epoch = obj.Epochs(find(obj.epochIDs == IDs));
        end

        function idx = id2idx(obj, IDs)
            idx = find(obj.epochIDs == IDs);
        end

        function value = getParameter(obj, paramName)
            if ~isKey(obj.datasetParameters, paramName)
                error('Parameter %s not found!', paramName);
            end
            value = obj.datasetParameters(paramName);
        end
    end

    methods
        function addRegions(obj, regions, overwrite)
            if nargin < 3
                overwrite = false;
            end
            assert(isa(regions, 'aod.core.Regions'), 'Input must be Regions object');
            if ~isempty(obj.Regions)
                if overwrite
                    obj.Regions = regions;
                else
                    error('Set overwrite=true to overwrite existing regions');
                end
            end
        end
    end

    methods 
        function imStack = getStacks(obj, epochIDs, varargin)
            ip = inputParser();
            addParameter(ip, 'Average', false, @islogical);
            parse(ip, varargin{:});
            avgFlag = ip.Results.Average;

            imStack = [];
            for i = 1:numel(epochIDs)
                epoch = obj.id2epoch(epochIDs(i));
                imStack = cat(4, imStack, epoch.getStack());
            end

            if avgFlag && ndims(imStack) == 4
                imStack = mean(imStack, 4);
            end
        end

        function data = getRegionResponses(obj, epochIDs, varargin)
            ip = inputParser();
            addParameter(ip, 'Average', false, @islogical);
            parse(ip, varargin{:});
            avgFlag = ip.Results.Average;

            data = [];
            for i = 1:numel(epochsIDs)
                epoch = obj.id2epoch(epochIDs(i));
                data = cat(3, data, epoch.getRegionResponses(ip.Unmatched));
            end

            if avgFlag && ndims(data) == 3
                data = mean(data, 3);
            end
        end
    end

    methods % (Access = ?aod.core.Creator)
        function addSource(obj, source)
            obj.Source = source;
        end

        function addParameter(obj, paramName, paramValue)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, paramValue)
            % -------------------------------------------------------------
            obj.datasetParameters(paramName) = paramValue;
        end

        function addEpoch(obj)
            assert(isa(epoch, 'aod.core.Epoch'), 'Input must be an Epoch');
            obj.Epochs = cat(1, obj.Epochs, epoch);
        end
    end
end
