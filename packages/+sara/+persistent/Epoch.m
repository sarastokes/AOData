classdef Epoch < aod.persistent.Epoch 

    properties (Hidden, Dependent)
        transform
    end
    
    properties (Hidden, Transient)
        cachedData
    end

    methods
        function obj = Epoch(varargin)
            obj = obj@aod.persistent.Epoch(varargin{:});
        end

        function value = get.transform(obj)
            value = [];
            if isempty(obj.Registrations)
                return
            end
            idx = find(findByClass(obj.Registrations,...
                'aod.builtin.registrations.RigidRegistration'));
        end
    end

    methods
        function fileName = getCoreVideoName(obj)
            fileName = obj.getExptFile('AnalysisVideo');
        end

        function imStack = getStack(obj, cacheFlag)
            if nargin < 2
                cacheFlag = false;
            end

            [~, fileName, ~] = fileparts(obj.getCoreVideoName);
            if ~isempty(obj.cachedData)
                imStack = obj.cachedData;
                fprintf('Loaded %s from cache\n', fileName);
                return 
            end

            fprintf('Loading %s...', fileName);

            videoName = obj.getCoreVideoName();
            imStack = im2double(readStack(videoName));
            imStack(:,:,1) = [];

            if ~isempty(obj.transform)
                fprintf('Applying transform...');
                imStack = obj.transform.apply(imStack);
            end

            if cacheFlag 
                obj.cachedData = imStack;
            end
        end
    end
end