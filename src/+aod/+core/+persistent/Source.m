classdef Source < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        SourcesContainer
    end

    methods
        function obj = Source(hdfFile, hdfName, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfName, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);
            
            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();           
            obj.SourcesContainer = obj.loadContainer('Sources');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Sources(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SourcesContainer(idx));
            end
        end
    end
end 