classdef Source < aod.persistent.Entity ...
        & matlab.mixin.Heterogeneous & dynamicprops

    properties (SetAccess = protected)
        SourcesContainer
    end

    methods
        function obj = Source(hdfFile, hdfName, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfName, factory);
        end
    end

    methods (Sealed)
        function obj = addSource(obj, source)
            % ADDSOURCE
            % 
            % Description:
            %   Add a Source to the Experiment and the HDF5 file
            %
            % Syntax:
            %   addAnalysis(obj, source)
            % -------------------------------------------------------------
            arguments
                obj
                source
            end

            source.setParent(obj);
            obj.addEntity(source);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);
            
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