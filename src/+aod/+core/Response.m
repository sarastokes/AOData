classdef Response < aod.core.Entity & matlab.mixin.Heterogeneous
% A response extracted from data acquired during an epoch
%
% Description:
%   A response extracted from data acquired during an Epoch
%
% Parent: 
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.Response(name, fileName, fileReader)
%
% Properties:
%   Data 
%   dateCreated
%
% Methods:
%   setData(obj, data)
%   addTiming(obj, timing)
%   clearTiming(obj)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data                             
        Timing (1,:)                            

        fileName            char
        fileReader          % aod.util.FileReader

        Dataset             aod.core.Dataset = aod.core.Dataset.empty()
    end

    methods
        function obj = Response(name, varargin)

            if nargin == 0
                name = [];
            end
            
            obj@aod.core.Entity(name, varargin{:});

            ip = inputParser();
            addParameter(ip, 'FileName', [], @ischar);
            addParameter(ip, 'Reader', [], @(x) isSubclass(x, 'aod.util.FileReader'));
            addParameter(ip, 'Dataset', [], @(x) isSubclass(x, 'aod.core.Dataset'));
            parse(ip, varargin{:});

            obj.setFileName(ip.Results.FileName);
            obj.setFileReader(ip.Results.Dataset);
            obj.setDataset(ip.Results.Dataset);
        end
    end

    methods (Sealed)
        function setFileReader(obj, reader)
            if isempty(reader)
                obj.fileReader = [];
                return
            end
            assert(isSubclass(reader, 'aod.util.FileReader'),...
                'Input must be a subclass of aod.util.FileReader');
            obj.fileReader = reader;
        end

        function setFileName(obj, fileName)
            if isempty(fileName)
                obj.fileName = '';
            elseif ~isempty(obj.Parent)
                tf = obj.Parent.hasFile(fileName);
                if ~tf
                    warning('setFileName:FileNotFound',...
                        'File %s not found in parent Epoch', fileName);
                end
                obj.fileName = fileName;
            end
        end

        function setDataset(obj, dataset)
            if isempty(dataset)
                obj.Dataset = aod.core.Dataset.empty();
            else
                if ~isSubclass(dataset, 'aod.core.Dataset')
                    error('setDataset:InvalidEntity',...
                        'Dataset must be aod.core.Dataset or subclass');
                end
                obj.Dataset = dataset;
            end

        end
    end

    methods (Sealed)
        function setData(obj, data)
            % SETDATA
            %
            % Syntax:
            %   setData(obj, data)
            % -------------------------------------------------------------
            obj.Data = data;
        end

        function setTiming(obj, timing)
            % SETTIMING
            %
            % Syntax:
            %   addTiming(obj, timing)
            % -------------------------------------------------------------
            assert(isnumeric(timing) || isduration(timing),...
                'Timing must be numeric or duration');
            obj.Timing = timing;
        end

        function clearTiming(obj)
            % CLEARTIMING
            %
            % Syntax:
            %   clearTiming(obj)
            % -------------------------------------------------------------
            obj.Timing = [];
        end
    end

    methods (Access = protected)
        function sync(obj)
            % Adopt epoch's timing if Response Timing is empty
            sync@aod.core.Entity(obj);
            if isempty(obj.Timing) && ~isempty(obj.Parent.Timing)
                obj.Timing = obj.Parent.Timing;
            end
        end
    end
end