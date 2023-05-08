classdef H5NodeTypes
% HDF5 file components
%
% Description:
%   Enumerated type for HDF5 file components
%
% Static methods:
%   obj = aod.app.util.H5NodeTypes.get(txt)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    enumeration
        NONE
        GROUP 
        DATASET 
        LINK 
    end

    methods (Static)
        function obj = get(nodeType)
            if isa(nodeType, 'aod.app.util.H5NodeTypes')
                obj = nodeType;
                return
            end

            import aod.app.util.H5NodeTypes

            switch lower(nodeType)
                case 'none'
                    obj = H5NodeTypes.NONE;
                case 'group'
                    obj = H5NodeTypes.GROUP;
                case 'dataset'
                    obj = H5NodeTypes.DATASET;
                case 'link'
                    obj = H5NodeTypes.LINK;
                otherwise
                    error('get:UnknownNodeType',...
                        'H5NodeTypes does not contain node %s', nodeType);
            end
        end
    end
end