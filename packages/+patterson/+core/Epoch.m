classdef Epoch < aod.core.Epoch
    
    methods
        function obj = Epoch(ID, parent)
            obj@aod.core.Epoch(ID, parent);
        end
    end

    methods (Access = protected)

        function videoName = getCoreVideoName(obj)
            videoName = obj.getFilePath('AnalysisVideo');
        end
    end


    % Overwritten methods
    methods 
        function imStack = getStack(obj)
            % GETSTACK
            if ~isempty(obj.cachedVideo)
                imStack = obj.cachedVideo;
                return;
            end

            videoName = obj.getCoreVideoName();
            imStack = obj.readStack(videoName);

            imStack(:,:,1) = [];

            obj.cachedVideo = imStack;
        end
    end
end

