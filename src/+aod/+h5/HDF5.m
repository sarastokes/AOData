classdef HDF5 < handle 
% HDF5
%
% Description:
%   Utility methods to simplify working with H5 files using both the
%   low-level HDF5 API and MATLAB's high-level built-in functions
%
% Methods:
%   fileID = openFile(fileName, readOnly)
%   deleteObject(fileName, pathName, name)
%   createGroups(fileName, pathName, varargin)
%   createGroup(locID, groupName, varargin)
%   makeMatrixDataset(fileName, pathName, dsetName, data)
%   dsetID = makeTextDataset(fileName, pathName, dsetName, txt)
%   dsetID = makeDateDataset(fileName, pathName, data)
%   makeCompoundDataset(fileName, pathName, dsetName, data)
%   writeatts(fileName, pathName, varargin)
%   createLink(fileName, targetPath, linkPath, linkName)
%
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
            %   groupID = createGroup(fileName, groupName, varargin)
            %
            % Notes:
            %   If no output argument is specified, the group is closed
            %   Continues on if group already exists
            % -------------------------------------------------------------

            if ischar(locID) && endsWith(locID, 'h5')
                locID = aod.h5.HDF5.openFile(locID);
            end

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

        function makeMatrixDataset(fileName, pathName, dsetName, data)
            % MAKEMATRIXDATASET
            % 
            % Description:
            %   Chains h5create and h5write for use with simple matrices
            %
            % Syntax:
            %   makeMatrixDataset(hdfFile, pathName, dsetName, data)
            % -------------------------------------------------------------
            fullPath = aod.h5.HDF5.buildPath(pathName, dsetName);

            try
                h5create(fileName, fullPath, size(data), 'Datatype', class(data));
            catch ME
                if strcmp(ME.identifier, 'MATLAB:imagesci:h5create:datasetAlreadyExists')
                    warning('Dataset %s already existed', fullPath);
                else
                    rethrow(ME);
                end
            end                    
            h5write(fileName, fullPath, data);
        end

        function dsetID = writeEnumDataset(hdfName, pathName, dsetName, value)
            % WRITEENUMDATASET
            %
            % Description:
            %   Create a pseudo enumerated type dataset
            %
            % Syntax:
            %   dsetID = writeEnumDataset(hdfName, pathName, dsetName, val)
            % -------------------------------------------------------------
            if isstring(dsetName)
                dsetName = char(dsetName);
            end
            dsetID = aod.h5.HDF5.makeTextDataset(hdfName, pathName, dsetName, char(value));
            aod.h5.HDF5.writeatts(hdfName, [pathName, '/', dsetName],... 
                'Class', 'enum', 'EnumClass', class(value));
            if nargout == 0
                H5D.close(dsetID);
            end
        end

        function dsetID = makeTextDataset(hdfIn, pathName, dsetName, txt) 
            % MAKETEXTDATASET
            %
            % Description:
            %   Create dataset for char/string data
            %
            % Syntax:
            %   dsetID = makeTextDataset(fileName, pathName, dsetName, txt)
            % -------------------------------------------------------------
            if isstring(dsetName)
                dsetName = char(dsetName);
            end
            if isa(hdfIn, 'H5ML.id')
                fileID = hdfIn;
            else
                fileID = aod.h5.HDF5.openFile(hdfIn);
            end
                
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
            H5D.write(dsetID, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', txt);

            H5T.close(typeID);
            H5S.close(dspaceID);
            if nargout == 0
                H5D.close(dsetID);
            end
            H5G.close(groupID);
            H5F.close(fileID);
        end

        function dsetID = makeDateDataset(fileName, pathName, dsetName, data)
            % MAKEDATEDATASET
            % 
            % Description:
            %   Saves datetime as text dataset with class and date format
            %   stored as attributes 
            %
            % Syntax:
            %   dsetID = makeDateDataset(fileName, pathName, data)
            % -------------------------------------------------------------
            import aod.h5.HDF5
            assert(isdatetime(data), 'makeDateDataset: data must be datetime');

            dsetID = HDF5.makeTextDataset(fileName, pathName, dsetName, datestr(data));
            HDF5.writeatts(fileName, HDF5.buildPath(pathName, dsetName),...
                'Class', 'datetime', 'Format', data.Format);
            if nargout == 0
                H5D.close(dsetID);
            end
        end

        function dsetID = makeStructDataset(fileName, pathName, dsetName, data)
            % MAKESTRUCTDATASET
            % -------------------------------------------------------------
            import aod.h5.HDF5

            fullPath = HDF5.buildPath(pathName, dsetName);

            if istable(data)
                data = table2struct(data);
            end

            dsetID = HDF5.makeTextDataset(fileName, pathName, dsetName, 'struct');
            f = fieldnames(data);
            for i = 1:numel(f)
                HDF5.writeatts(fileName, fullPath, f{i}, HDF5.data2att(data.(f{i})));
            end
            if nargout == 0
                H5D.close(dsetID);
            end
        end

        function dsetID = makeCompoundDataset(fileName, pathName, dsetName, data)
            % MAKECOMPOUNDDATASET
            %
            % Description:
            %   Adds table/struct to HDF5 file as compound
            %
            % Syntax:
            %   dsetID = makeCompoundDataset(fileName, pathName, table);
            % -------------------------------------------------------------
            import aod.h5.HDF5

            fullPath = HDF5.buildPath(pathName, dsetName);

            % Record original class, then convert to struct
            dataClass = class(data);
            if istable(data)
                nDims = height(data);
                data = table2struct(data);
            else
                nDims = max(@numel, data);
            end

            fileID = aod.h5.HDF5.openFile(fileName);
        
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
                elseif isstring(val) && numel(val) == 1
                    val = char(val);
                end
                typeIDs{i} = HDF5.getDataType(val);
                sizes(i) = H5T.get_size(typeIDs{i});
            end
        
            typeID = H5T.create('H5T_COMPOUND', sum(sizes));
            for i = 1:length(names)
                % Insert columns into compound type
                H5T.insert(typeID, names{i}, sum(sizes(1:i-1)), typeIDs{i});
            end
            % Optimizes for type size
            H5T.pack(typeID);
        
            spaceID = H5S.create_simple(1, nDims, []);
            if aod.h5.HDF5.exists(fileName, fullPath)
                warning('found and replaced %s', fullPath);
                HDF5.deleteObject(fileName, fullPath);
            end
            dsetID = H5D.create(fileID, fullPath, typeID, spaceID, 'H5P_DEFAULT');
            H5D.write(dsetID, typeID, spaceID, spaceID, 'H5P_DEFAULT', data);

            % Cleanup
            H5T.close(typeID);
            H5S.close(spaceID);
            if nargout == 0
                H5D.close(dsetID);
            end
            H5F.close(fileID);
            
            % Write original class as an attribute 
            HDF5.writeatts(fileName, fullPath, 'Class', dataClass);
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
            % Description:
            %   Creates a soft link within HDF5 file
            %
            % Syntax:
            %   createLink(fileName, targetPath, linkPath, linkName)
            % -------------------------------------------------------------
            if aod.h5.HDF5.exists(fileName, [linkPath, '/', linkName])
                warning('LinkExists: Skipped existing link at %s', linkPath);
                return
            end
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
            elseif isdatetime(data)
                out = datestr(data);
            elseif isstring(data) && numel(data) == 1
                out = char(data);
            else
                out = data;
            end
        end

        function tf = writeDataByType(fileName, pathName, dsetName, data)
            % WRITEDATABYTYPE
            %
            % Description:
            %   Call the appropriate "make" function for given data type 
            %   and tags with original MATLAB class information
            %
            % Syntax:
            %   tf = writeDataByType(fileName, pathName, dsetName, data)
            % -------------------------------------------------------------
            import aod.h5.HDF5

            if isstring(dsetName)
                dsetName = char(dsetName);
            end

            fullPath = HDF5.buildPath(pathName, dsetName);

            tf = true;

            if isenum(data)
                HDF5.makeEnumDataset(fileName, pathName, dsetName, data);
            elseif isstruct(data) || istable(data)
                try
                    HDF5.makeCompoundDataset(fileName, pathName, dsetName, data);
                    HDF5.writeatts(fileName, fullPath, 'Class', class(data));
                catch
                    % Delete dataset created while attempting compound type
                    if aod.h5.HDF5.exists(fileName, fullPath)
                        HDF5.deleteObject(fileName, fullPath);
                    end
                    HDF5.makeStructDataset(fileName, pathName, dsetName, data);
                end
            elseif isnumeric(data)
                HDF5.makeMatrixDataset(fileName, pathName, dsetName, data);
                HDF5.writeatts(fileName, fullPath, 'Class', class(data));
            elseif ischar(data)
                HDF5.makeTextDataset(fileName, pathName, dsetName, data);
                HDF5.writeatts(fileName, fullPath, 'Class', class(data));
            elseif isstring(data)
                HDF5.makeTextDataset(fileName, pathName, dsetName, char(data));
                HDF5.writeatts(fileName, fullPath, 'Class', class(data));
            elseif isdatetime(data)
                HDF5.makeDateDataset(fileName, pathName, dsetName, data);
            else
                tf = false;
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
            elseif isstring(var) && numel(var) == 1
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
                path = [path, '/', char(varargin{i})];  %#ok
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

% if isstring(prop) && numel(prop) > 1
%    HDF5.makeMatrixDataset(hdfName, hdfPath, persistedProps(i), prop);
% else
%     HDF5.makeTextDataset(hdfName, hdfPath, persistedProps(i), prop);
% end