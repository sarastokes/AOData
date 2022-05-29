classdef Dataset < aod.core.Dataset
    
    methods
        function obj = Dataset(homeDirectory, expDate)
            obj = obj@aod.core.Dataset(homeDirectory, expDate);
        end

        function value = getFileHeader(obj)
            value = [num2str(obj.Source.Parent.ID), '_', char(obj.experimentDate)];
        end
    end

    methods 
        function clearAllCachedVideos(obj)
            for i = 1:numel(obj.Epochs)
                obj.Epochs(i).clearVideoCache();
            end
        end

        function clearAllTransforms(obj)
            for i = 1:numel(obj.Epochs)
                obj.Epochs(i).clearTransform();
            end
        end

        function loadTransforms(obj, tforms, epochIDs)
            if ischar(tforms)
                TR = ao.builtin.RigidTransformReader(tforms);
                tforms = tformReader.read();
                assert(TR.Count == numel(epochIDs), ...
                    'Epoch IDs does not match number of transforms');
            end

            for i = 1:numel(epochIDs)
                obj.Epochs(obj.idx2epoch(epochIDs(i))).setTransform(...
                    affine2d_to_3d(squeeze(tforms(:,:,i))));
            end
        end
    end

    methods
        function initParameters(obj, varargin)
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'Experimenter', '', @ischar);
            addParameter(ip, 'System', '', @ischar);
            addParameter(ip, 'Purpose', '', @ischar);
            parse(ip, varargin{:});

            obj.addParserToParams(obj.datasetParameters, ip.Results);
        end

        function value = getEpochHeader(obj)
            value = [num2str(obj.Source.ID), '_', char(obj.experimentDate)];
        end
    end
end
