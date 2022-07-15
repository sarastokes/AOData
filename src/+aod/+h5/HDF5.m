classdef HDF5 < handle 
% HDF5
%
% Description:
%   Utility methods to simplify working with H5 files using both the
%   low-level HDF5 API and MATLAB's high-level built-in functions
%
% Methods:
%   openFile(fileName, readOnly)
%   deleteGroup()
%   createGroups(fileName, pathName, varargin)
%   createGroup(locID, groupName, varargin)
%   makeTextDataset(fileName, pathName, dsetName, txt)
%   makeTableDataset(fileName, pathName, dsetName, txt)
%   writeatts(fileName, pathName, varargin)
%   createLink(fileName, targetPath, linkPath, linkName)
%   tf = exists(fileName, pathName)
%   path = buildPath(varargin)
%   parentPath = getParentPath(pathName)
%   lastObject = getPathEnd(pathName)
% 
% History:
%   17Jan2022 - SSP
%   08Jun2022 - SSP - Additions to ao-data-tools
% -------------------------------------------------------------------------

    properties (Hidden, Constant)
        NEW_GROUP_PROPS = {'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT'};
    end

    methods (Static)
        function fileID = openFile(fileName, readOnly)
            % OPENFILE
            %
            % Syntax:
            %   fileID = openFile(fileName, readOnly)
            %
            % Inputs:
            %   fileName        char, HDF5 file name
            % Optional inputs:
            %   readOnly        logical, default = false
            % -------------------------------------------------------------
            if nargin < 2
                readOnly = false;
            end

            if readOnly
                fileID = H5F.open(fileName, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            else
                fileID = H5F.open(fileName, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
            end
        end

        function createGroups(fileName, pathName, varargin)
            % CREATEGROUP
            % 
            % Description:
            %   Create one or more groups at a specific location
            %
            % Syntax:
            %   groupID = createGroup(fileName, pathName, varargin)
            %
            % Inputs:
            %   varargin        New group name(s)
            % -------------------------------------------------------------
            
            fileID = aod.h5.HDF5.openFile(fileName);
            for i = 1:numel(varargin)
                try
                    groupPath = aod.h5.HDF5.buildPath(pathName, varargin{i});
                    groupID = H5G.create(fileID, groupPath, aod.h5.HDF5.NEW_GROUP_PROPS);
                    H5G.close(groupID);
                catch ME
                    if contains(ME.message, 'name already exists')
                        warning('aod.h5.HDF5:Group %s already exists, skipping', groupPath);
                    else
                        rethrow(ME);
                    end
                end
            end
            H5F.close(fileID);
        end

        function groupID = createGroup(locID, groupName, varargin)
            % CREATEGROUP
            % 
            % Description:
            %   Create one or more groups at a specific location
            %
            % Syntax:
            %   groupID = createGroup(locID, groupName, varargin)
            %
            % Notes:
            %   If no output argument is specified, the group is closed
            %   Continues on if group already exists
            % -------------------------------------------------------------
            if ~aod.h5.HDF5.exists(locID, groupName)   
                groupID = H5G.create(locID, groupName, aod.h5.HDF5.NEW_GROUP_PROPS);
                if nargout == 0
                    H5G.close(groupID);
                end
            end
            % Call again for additional groups
            if nargin > 2
                for i = 1:numel(varargin)
                    aod.h5.HDF5.createGroup(locID, varargin{i});
                end
            end
        end

        function makeMatrixDataset(fileName, pathName, data)
            % CREATEWRITEMATRIX
            % 
            % Description:
            %   Chains h5create and h5write for use with simple matrices
            %
            % Syntax:
            %   h5createwrite(hdfFile, pathName, data)
            %
            % -------------------------------------------------------------
            try
                h5create(fileName, pathName, size(data));
            catch ME
                if strcmp(ME.identifier, 'MATLAB:imagesci:h5create:datasetAlreadyExists')
                    warning('Dataset %s already existed, continuing', targetPath);
                else
                    rethrow(ME);
                end
            end
                    
            h5write(hdfFile, targetPath, data);
        end

        function dsetID = makeTextDataset(fileName, pathName, dsetName, txt) 
            % MAKETEXTDATASET
            %
            % Syntax:
            %   dsetID = makeDatasetText(fileName, pathName, dsetName, txt)
            % -------------------------------------------------------------
            fileID = aod.h5.HDF5.openFile(fileName);
                
            typeID = H5T.copy('H5T_C_S1');
            H5T.set_size(typeID, 'H5T_VARIABLE');
            H5T.set_strpad(typeID,'H5T_STR_NULLTERM');
            dspaceID = H5S.create('H5S_SCALAR');
            % Get the parent group, create if doesn't exist
            try
                groupID = H5G.open(fileID, pathName);
            catch ME
                if contains(ME.message, 'doesn''t exist')
                    groupID = H5G.create(fileID, pathName, aod.h5.HDF5.NEW_GROUP_PROPS);
                else
                    rethrow(ME);
                end
            end
            % Get the dataset
            try
                dsetID = H5D.create(groupID, dsetName, typeID, dspaceID, 'H5P_DEFAULT');
            catch ME
                if contains(ME.message, 'name already exists')
                    dsetID = H5D.open(groupID, dsetName, 'H5P_DEFAULT');
                else
                    rethrow(ME);
                end
            end
            H5T.close(typeID);
            H5S.close(dspaceID);
            H5D.write(dsetID, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', txt);
            if nargout == 0
                H5D.close(dsetID);
            end
            H5G.close(groupID);
            H5F.close(fileID);
        end

        function dsetID = makeTableDataset(fileName, pathName, data)
            % MAKETABLEDATSET
            %
            % Description:
            %   Adds table to HDF5 file as compound
            %
            % Syntax:
            %   dsetID = makeTableDataset(fileName, pathName, table);
            %
            % Notes:
            %   Appreciative to NWB for showing the way on this one:
            %   https://github.com/NeurodataWithoutBorders/matnwb/+io/writeCompound.m
            % -------------------------------------------------------------
        
            fileID = aod.h5.HDF5.openFile(fileName);
            nRows = height(data);
            data = table2struct(data);
        
            names = fieldnames(data);
        
            S = struct();
            for i = 1:length(names) 
                S.(names{i}) = {data.(names{i})};
            end
            data = S;
        
            typeIDs = cell(length(names), 1);
            sizes = zeros(size(typeIDs));
        
            for i = 1:length(names)
                val = data.(names{i});
                if iscell(val) && ~isstring(val)
                    data.(names{i}) = [val{:}];
                    val = val{1};
                end
                typeIDs{i} = aod.h5.HDF5.getDataType(val);
                sizes(i) = H5T.get_size(typeIDs{i});
            end
        
            typeID = H5T.create('H5T_COMPOUND', sum(sizes));
            for i = 1:length(names)
                % Insert columns into compound type
                H5T.insert(typeID, names{i}, sum(sizes(1:i-1)), typeIDs{i});
            end
            % Optimizes for type size
            H5T.pack(typeID);
        
            spaceID = H5S.create_simple(1, nRows, []);
            if aod.h5.HDF5.exists(fileName, pathName)
                warning('found and replaced %s', pathName);
                aod.h5.HDF5.deleteObject(fileName, pathName);
            end
            dsetID = H5D.create(fileID, pathName, typeID, spaceID, 'H5P_DEFAULT');
            H5D.write(dsetID, typeID, spaceID, spaceID, 'H5P_DEFAULT', data);
            H5S.close(spaceID);
            if nargout == 0
                H5D.close(dsetID);
            end
            H5F.close(fileID);
        end
        
        function deleteObject(fileName, pathName, name)
            % DELETEOBJECT
            %
            % Description:
            %   Delete a group or dataset
            %
            % Syntax:
            %   aod.h5.HDF5.deleteObject(fileID, pathName, name);
            % -------------------------------------------------------------
            if nargin == 2
                name = aod.h5.HDF5.getPathEnd(pathName);
                pathName = aod.h5.HDF5.getPathParent(pathName);
            end
            fileID = aod.h5.HDF5.openFile(fileName);
            if pathName == '/'
                parentID = fileID;
            else
                parentID = H5G.open(fileID, pathName);
            end
            H5L.delete(parentID, name, 'H5P_DEFAULT');
            if pathName ~= '/' 
                H5G.close(parentID);
            end
            H5F.close(fileID);
        end

        function writeatts(fileName, pathName, varargin)
            % WRITEATTS
            % 
            % Description:
            %   Write one or more attributes at a specific location
            %
            % Syntax:
            %   aod.h5.HDF5.writeatts(fileName, pathName, varargin)
            %
            % varargin may be a containers.Map of attributes or a list of
            % attributes specified as key, value
            % -------------------------------------------------------------
            if isSubclass(varargin{1}, 'containers.Map')
                attMap = varargin{1};
            else
                attMap = kv2map(varargin{:});
            end
            if isempty(attMap)
                return
            end
            k = attMap.keys;
            for i = 1:numel(k)
                h5writeatt(fileName, pathName, k{i},...
                    aod.h5.HDF5.data2att(attMap(k{i})));
            end
        end

        function createLink(fileName, targetPath, linkPath, linkName)
            % CREATELINK 
            %
            % Syntax:
            %   createLink(fileName, targetPath, linkPath, linkName)
            % -------------------------------------------------------------
            fileID = aod.h5.HDF5.openFile(fileName);
            linkID = H5G.open(fileID, linkPath);
            H5L.create_soft(targetPath, linkID, linkName, 'H5P_DEFAULT', 'H5P_DEFAULT');
            H5G.close(linkID);
            H5F.close(fileID);
        end
    end

    % Data type methods
    methods (Static)
        function out = data2att(data)
            if islogical(data)
                out = int32(data);
            else
                out = data;
            end
        end

        function writeDataByType(fileName, pathName, data)
            % WRITEDATABYTYPE
            %
            % Description:
            %   Call the appropriate "make" function for given data type
            %
            % Syntax:
            %   writeDataByType(fileName, pathName, data)
            % -------------------------------------------------------------
            if istable(data)
                aod.h5.HDF5.makeTableDataset(fileName, pathName, data);
                aod.h5.HDF5.writeatts(fileName, pathName, 'EntityType', 'table');
            elseif isdouble(data)
                aod.h5.HDF5.makeMatrixDataset(fileName, pathName, data);
            elseif ischar(data)
                aod.h5.HDF5.makeTextDataset(fileName, pathName, data);
            elseif isstring(data)
                aod.h5.HDF.makeTextDataset(fileName, pathName, char(data));
            elseif isdatetime(data)
                aod.h5.HDF5.makeTextDataset(fileName, pathName, datestr(data));
                aod.h5.HDF5.writeatts(fileName, pathName, 'EntityType', 'date');
            end
        end    

        function typeID = getDataType(var)
            % GETDATATYPE
            %
            % Description:
            %   Maps MATLAB data types to H5 data types (incomplete)
            %
            % Syntax:
            %   typeID = getDataType(var)
            % -------------------------------------------------------------
            if isa(var, 'double')
                typeID = 'H5T_IEEE_F64LE';
            elseif ismember(class(var), {'char', 'cell', 'datetime'})
                typeID = H5T.copy('H5T_C_S1');
                H5T.set_size(typeID, 'H5T_VARIABLE');
            elseif islogical(var)
                typeID = 'H5T_STD_I32LE';
            elseif isa(var, 'uint8')
                typeID = 'H5T_STD_U8LE';
            end
        end
    end

    % Query functions
    methods (Static)
        function tf = exists(fileName, pathName)
            % EXISTS
            % 
            % Check if group or dataset exists in file
            %
            % Syntax:
            %   tf = exists(fileName, pathName)
            %
            % Inputs:
            %   fileName        char H5 file name OR H5ML.id
            % -------------------------------------------------------------
            if isa(fileName, 'H5ML.id')
                tf = H5L.exists(fileName, pathName, 'H5P_DEFAULT');
            else
                fileID = aod.h5.HDF5.openFile(fileName);
                try
                    tf = H5L.exists(fileID, pathName, 'H5P_DEFAULT');
                catch ME
                    if contains(ME.message, 'component not found')
                        error('Parent group not found: %s', pathName);
                    else
                        rethrow(ME);
                    end
                end
                H5F.close(fileID);
            end
        end

        function x = getGroupNames(fileName, pathName)
            if nargin == 1
                pathName = '\';
            end
            
            S = h5info(fileName, pathName);
            x = arrayfun(@(x) string(x.Name), S.Groups);
        end
        
        function x = getDatasetNames(fileName, pathName)
            if nargin == 1
                pathName = '\';
            end

            S = h5info(fileName, pathName);
            x = arrayfun(@(x) string(x.Name), S.Datasets);
        end

        function [x, S] = getAttributeNames(fileName, pathName)
            if nargin == 1
                pathName = '\';
            end
            S = h5info(fileName, pathName);
            x = arrayfun(@(x) string(x.Name), S.Attributes);
        end
    end

    % Utility methods
    methods (Static)
        function path = buildPath(varargin)
            % BUILDPATH
            %
            % Description:
            %   Concatenates names into valid HDF5 path
            %
            % Syntax:
            %   path = buildPath(varargin)
            %
            % Example:
            %   buildPath('Group1', 'Group2')
            %       returns '/Group1/Group2'
            % -------------------------------------------------------------
            path = [];
            for i = 1:nargin
                path = [path, '/', varargin{i}];  %#ok
            end

            % Make sure leading / isn't duplicated
            if strcmp(1, '/') && strcmp(2, '/')
                path = path(2:end);
            end
        end

        function parentPath = getPathParent(pathName)
            % GETPATHPARENT
            % 
            % Description:
            %   Removes last identifier in path name, returning parent 
            %
            % Syntax:
            %   parentPath = getPathParent(pathName)
            % -------------------------------------------------------------

            idx = strfind(pathName, '/');
            if numel(idx) == 1 && idx == 1
                parentPath = '/';
            else
                parentPath = pathName(1:idx(end)-1);
            end
        end

        function lastName = getPathEnd(pathName)
            % GETPATHEND
            % 
            % Description:
            %   Extracts the final group/dataset from a full path 
            %
            % Syntax:
            %   parentPath = getPathParent(pathName)
            % -------------------------------------------------------------
            idx = strfind(pathName, '/');
            lastName = pathName(idx(end)+1:end);
        end
    end
end 