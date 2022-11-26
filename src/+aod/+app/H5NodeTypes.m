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
        function obj = init(nodeType)
            if isa(nodeType, 'aod.app.NodeTypes')
                obj = nodeType;
                return
            end

            import aod.app.H5NodeTypes

            switch lower(nodeType)
                case 'none'
                    obj = H5NodeTypes.NONE;
                case 'group'
                    obj = H5NodeTypes.GROUP;
                case 'dataset'
                    obj = H5NodeTypes.DATASET;
                case 'link'
                    obj = H5NodeTypes.LINK;
            end
        end
    end
end