classdef H5NodeTypes
% AONODETYPES
%
% Description:
%   Enumerated type for HDF5 file components
%
% Static methods:
%   obj = get(txt)
% -------------------------------------------------------------------------

    enumeration
        NONE
        GROUP 
        DATASET 
        LINK 
    end

    methods (Static)
        function obj = get(nodeType)
            if isa(nodeType, 'aod.app.NodeTypes')
                obj = nodeType;
                return
            end

            import aod.app.H5NodeTypes

            switch lower(nodeTypes)
                case 'none'
                    obj = NodeTypes.NONE;
                case 'group'
                    obj = NodeTypes.GROUP;
                case 'dataset'
                    obj = NodeTypes.DATASET;
                case 'link'
                    obj = NodeTypes.LINK;
            end
        end
    end
end