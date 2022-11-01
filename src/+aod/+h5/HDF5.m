classdef HDF5 < handle 
% HDF5
%
% Description:
%   Utility methods to simplify working with H5 files using both the
%   low-level HDF5 API and MATLAB's high-level built-in functions
%
% File Methods:
%   fileID = createFile(fileName, overwrite)
%   fileID = openFile(fileName, readOnly)
%
%   createGroups(fileName, pathName, varargin)
%   createGroup(locID, groupName, varargin)
%   groupNames = collectGroups(fileName)
%
%   makeMatrixDataset(fileName, pathName, dsetName, data)
%   makeEnumDataset(fileName, pathName, dsetName, data)
%   makeTextDataset(fileName, pathName, dsetName, txt)
%   makeDateDataset(fileName, pathName, data)
%   makeStructDataset(fileName, pathName, dsetName, data)
%   makeCompoundDataset(fileName, pathName, dsetName, data)
%   makeStringDataset(fileName, pathName, dsetName, data)
%
%   deleteObject(fileName, pathName, name)
%
%   tf = hasAttribute(fileName, pathName, paramName)
%   names = getAttributeNames(fileName, pathName)
%   deleteAttribute(fileName, pathName, name)
%   writeatts(fileName, pathName, varargin)
%
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
%   22Aug2022 - SSP - Dataset ID no longer return option for make methods
%   04Sep2022 - SSP - Stricter type checking for char inputs
% -------------------------------------------------------------------------

    properties (Hidden, Constant)
        NEW_GROUP_PROPS = {'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT'};
    end

    % File-level methods
    methods (Static)
        function fileID = createFile(fileName, overwrite)
            % CREATEFILE
            %
            % Syntax:
            %   fileID = openFile(fileName, overwrite)
            %
            % Inputs:
            %   fileName            char, HDF5 file name
            % Optional inputs:
            %   overwrite           logical, default = false
            % -------------------------------------------------------------
            arguments
                fileName            
                overwrite           logical                     = false
            end

            assert(endsWith(fileName, '.h5'), 'File name must end with .h5');

            if exist(fileName, 'file')
                if overwrite
                    delete(fileName);
                else
                    error("createFile:FileExists",...
                        "File already exists, set overwrite=true to recreate");
                end
            end

            fileID = H5F.create(fileName);
            if nargout == 0
                fileIDx = onCleanup(@()H5F.close(fileID));
            end
            fprintf('Created HDF5 file: %s\n', fileName);
        end

        function fileID = openFile(fileName, readOnly)
            % OPENFILE
            %
            % Syntax:
            %   fileID = openFile(fileName, readOnly)
            %
            % Inputs:
            %   fileName        char, HDF5 file name
            % Optional inputs:
            %   readOnly        logical, default = true
            % -------------------------------------------------------------
            arguments
                fileName {mustBeFile(fileName)}
                readOnly logical = true
            end

            if readOnly
                fileID = H5F.open(fileName, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            else
                fileID = H5F.open(fileName, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
            end

        end
    end

    % Group methods
    methods (Static)
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
            if isstring(pathName)
                pathName = char(pathName);
            end

            fileID = aod.h5.HDF5.openFile(fileName, false);
            fileIDx = onCleanup(@()H5F.close(fileID));
            for i = 1:numel(varargin)
                try
                    groupPath = aod.h5.HDF5.buildPath(pathName, varargin{i});
                    groupID = H5G.create(fileID, groupPath, aod.h5.HDF5.NEW_GROUP_PROPS);
                    groupIDx = onCleanup(@()H5G.close(groupID));
                catch ME
                    if contains(ME.message, 'name already exists')
                        warning('aod.h5.HDF5:Group %s already exists, skipping', groupPath);
                    else
                        rethrow(ME);
                    end
                end
            end
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
            if ~aod.h5.HDF5.exists(locID, groupName)   
                if ischar(locID) && endsWith(locID, 'h5')
                    locID = aod.h5.HDF5.openFile(locID, false);
                end
                groupID = H5G.create(locID, groupName, aod.h5.HDF5.NEW_GROUP_PROPS);
                if nargout == 0            
                    groupIDx = onCleanup(@()H5G.close(groupID));
                end
            end
            % Call again for additional groups
            if nargin > 2
                for i = 1:numel(varargin)
                    aod.h5.HDF5.createGroup(locID, varargin{i});
                end
            end
        end

        function groupNames = collectGroups(hdfName)
            % COLLECTGROUPS
            %
            % Description:
            %   Collect all the group names in an HDF file or subfilee
            %
            % Syntax:
            %   groupNames = collectGroups(hdfName)
            %
            % Inputs:
            %   hdfName         either file name or H5ML.id
            %
            % See also:
            %   groupVisitFcn
            % -------------------------------------------------------------
            if ~isa(hdfName, 'H5ML.id')
                rootID = aod.h5.HDF5.openFile(hdfName, true);
                rootIDx = onCleanup(@()H5F.close(rootID));
            else
                rootID = hdfName;
            end

            groupNames = string.empty();
            [~, groupNames] = H5O.visit(rootID, 'H5_INDEX_NAME',... 
                'H5_ITER_NATIVE', @groupVisitFcn, groupNames);
        end
    end

    % Dataset methods
    methods (Static)   
        function makeMatrixDataset(fileName, pathName, dsetName, data)
            % MAKEMATRIXDATASET
            % 
            % Description:
            %   Chains h5create and h5write for use with simple matrices
            %
            % Syntax:
            %   makeMatrixDataset(hdfFile, pathName, dsetName, data)
            % -------------------------------------------------------------
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char
                dsetName            char 
                data                {mustBeNumeric(data)}
            end

            fullPath = aod.h5.HDF5.buildPath(pathName, dsetName);

            try
                h5create(fileName, fullPath, size(data), 'Datatype', class(data));
            catch ME
                if ~strcmp(ME.identifier, 'MATLAB:imagesci:h5create:datasetAlreadyExists')
                    rethrow(ME);
                end
            end                    
            h5write(fileName, fullPath, data);
        end

        function makeEnumDataset(fileName, pathName, dsetName, value)
            % MAKEENUMDATASET
            %
            % Description:
            %   Create a pseudo enumerated type dataset
            %
            % Syntax:
            %   makeEnumDataset(hdfName, pathName, dsetName, val)
            % -------------------------------------------------------------
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char
                dsetName            char 
                value                
            end

            aod.h5.HDF5.makeTextDataset(fileName, pathName, dsetName, char(value));
            aod.h5.HDF5.writeatts(fileName, [pathName, '/', dsetName],... 
                'Class', 'enum', 'EnumClass', class(value));
        end

        function makeTextDataset(hdfIn, pathName, dsetName, txt) 
            % MAKETEXTDATASET
            %
            % Description:
            %   Create dataset for char/string data
            %
            % Syntax:
            %   makeTextDataset(fileName, pathName, dsetName, txt)
            % -------------------------------------------------------------
            arguments
                hdfIn            
                pathName            char
                dsetName            char 
                txt
            end

            if isa(hdfIn, 'H5ML.id')
                fileID = hdfIn;
            else
                fileID = aod.h5.HDF5.openFile(hdfIn, false);
                fileIDx = onCleanup(@()H5F.close(fileID));
            end
                
            typeID = H5T.copy('H5T_C_S1');
            typeIDx = onCleanup(@()H5T.close(typeID));
            H5T.set_size(typeID, 'H5T_VARIABLE');
            H5T.set_strpad(typeID, 'H5T_STR_NULLTERM');

            dspaceID = H5S.create('H5S_SCALAR');
            dspaceIDx = onCleanup(@()H5S.close(dspaceID));
            
            % Get the parent group, create if doesn't exist
            try
                groupID = H5G.open(fileID, pathName);
                groupIDx = onCleanup(@()H5G.close(groupID));
            catch ME
                if contains(ME.message, 'doesn''t exist')
                    groupID = H5G.create(fileID, pathName, aod.h5.HDF5.NEW_GROUP_PROPS);
                    groupIDx = onCleanup(@()H5G.close(groupID));
                else
                    rethrow(ME);
                end
            end

            % Get the dataset
            try
                dsetID = H5D.create(groupID, dsetName, typeID, dspaceID, 'H5P_DEFAULT');
                dsetIDx = onCleanup(@()H5D.close(dsetID));
            catch ME
                if contains(ME.message, 'name already exists')
                    dsetID = H5D.open(groupID, dsetName, 'H5P_DEFAULT');
                    dsetIDx = onCleanup(@()H5D.close(dsetID));
                else
                    rethrow(ME);
                end
            end
            H5D.write(dsetID, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', txt);
        end

        function makeStringDataset(fileName, pathName, dsetName, data)
            % MAKESTRINGDATASET
            %
            % Description:
            %   Write a string array dataset
            %
            % Syntax:
            %   makeStringDataset(fileName, pathName, dsetName, data)
            % ------------------------------------------------------------
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char
                dsetName            char 
                data                string
            end

            fullPath = aod.h5.HDF5.buildPath(pathName, dsetName);
            if ~aod.h5.HDF5.exists(fileName, fullPath)
                h5create(fileName, fullPath, size(data),...
                    'DataType', 'string');
            end
            h5write(fileName, fullPath, data);
        end

        function makeDateDataset(fileName, pathName, dsetName, data)
            % MAKEDATEDATASET
            % 
            % Description:
            %   Saves datetime as text dataset with class and date format
            %   stored as attributes 
            %
            % Syntax:
            %   makeDateDataset(fileName, pathName, data)
            % -------------------------------------------------------------
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char
                dsetName            char 
                data                datetime
            end

            import aod.h5.HDF5

            HDF5.makeTextDataset(fileName, pathName, dsetName, datestr(data));
            HDF5.writeatts(fileName, HDF5.buildPath(pathName, dsetName),...
                'Class', 'datetime', 'Format', data.Format);
        end

        function makeStructDataset(fileName, pathName, dsetName, data)
            % MAKESTRUCTDATASET
            %
            % Description:
            %    Hack to write struct/table when makeCompoundDataset fails
            %
            % Syntax:
            %   makeStructDataset(fileName, pathName, dsetName, data)
            % -------------------------------------------------------------
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char
                dsetName            char 
                data
            end

            import aod.h5.HDF5

            fullPath = HDF5.buildPath(pathName, dsetName);

            if istable(data)
                data = table2struct(data);
            end

            HDF5.makeTextDataset(fileName, pathName, dsetName, 'struct');
            
            f = fieldnames(data);
            columnClasses = [];
            for i = 1:numel(f)
                HDF5.writeatts(fileName, fullPath, f{i}, HDF5.data2att(data.(f{i})));
                columnClasses = [columnClasses, '; ', class(data.(f{i}))];
            end
            columnClasses = columnClasses(3:end);
            HDF5.writeatts(fileName, filePath, 'ColumnClass', columnClasses);
        end

        function makeCompoundDataset(fileName, pathName, dsetName, data)
            % MAKECOMPOUNDDATASET
            %
            % Description:
            %   Adds table/struct to HDF5 file as compound
            %
            % Syntax:
            %   makeCompoundDataset(fileName, pathName, table);
            % -------------------------------------------------------------
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char 
                dsetName            char 
                data 
            end

            import aod.h5.HDF5

            fullPath = HDF5.buildPath(pathName, dsetName);

            % Record original class and column classes
            dataClass = class(data);
            columnClass = [];
            colsToFix = [];
            if istable(data)
                for i = 1:size(data, 2)
                    if iscellstr(data{:,i})
                        % fix for cellstr is being transposed oddly 
                        columnClass = [columnClass, ', ', 'cellstr']; %#ok<*AGROW> 
                        colsToFix = cat(2, colsToFix, i);
                    else
                        columnClass = [columnClass, ', ', class(data{:,i})];  
                    end
                end

                columnClass = columnClass(3:end); % FIX
                for i = 1:numel(colsToFix)
                    % Am I missing something, why is this so hard
                    colData = string(data{:,colsToFix}')';
                    varName = data.Properties.VariableNames{colsToFix(i)};
                    data = removevars(data, colsToFix(i));
                    data.(varName) = colData;
                    data = movevars(data, varName, 'Before', colsToFix(i));
                end
                nDims = height(data);
                data = table2struct(data);
            else
                f = fieldnames(data);
                for i = 1:numel(f)
                    columnClass = [columnClass, ', ', class(data.(f{i}))];
                end
                nDims = max(@numel, data);
            end

            fileID = aod.h5.HDF5.openFile(fileName, false);
            fileIDx = onCleanup(@()H5F.close(fileID));
        
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
            typeIDx = onCleanup(@(x)H5T.close(typeID));
            for i = 1:length(names)
                % Insert columns into compound type
                H5T.insert(typeID, names{i}, sum(sizes(1:i-1)), typeIDs{i});
            end
            % Optimizes for type size
            H5T.pack(typeID);
        
            spaceID = H5S.create_simple(1, nDims, []);
            spaceIDx = onCleanup(@()H5S.close(spaceID));
            if aod.h5.HDF5.exists(fileID, fullPath)
                warning('found and replaced %s', fullPath);
                HDF5.deleteObject(fileName, fullPath);
            end
            dsetID = H5D.create(fileID, fullPath, typeID, spaceID, 'H5P_DEFAULT');
            dsetIDx = onCleanup(@()H5D.close(dsetID));

            H5D.write(dsetID, typeID, spaceID, spaceID, 'H5P_DEFAULT', data);

            % Write original class and column classes attributes
            HDF5.writeatts(fileName, fullPath, 'Class', dataClass,...
                'ColumnClass', columnClass);
        end
    end

    % Attribute methods
    methods (Static)
        function tf = hasAttribute(hdfName, pathName, paramName)
            % HASATTRIBUTENAME
            %
            % Description:
            %   Determine whether a specific attribute is present
            %
            % Syntax:
            %   tf = hasAttribute(hdfName, pathName, paramName)
            % -------------------------------------------------------------
            arguments
                hdfName             {mustBeFile(hdfName)}
                pathName            char
                paramName           string
            end
            
            attNames = aod.h5.HDF5.getAttributeNames(hdfName, pathName);
            tf = ismember(paramName, attNames);
        end

        function names = getAttributeNames(hdfName, pathName)
            % GETALLATTRIBUTENAMES
            %
            % Description:
            %   Return all attribute names (faster than getAttributeNames)
            %
            % Syntax:
            %   names = getAllAttributeNames(hdfName, pathName)
            % -------------------------------------------------------------
            arguments
                hdfName            {mustBeFile(hdfName)} 
                pathName            char = '\'
            end

            fileID = H5F.open(hdfName);
            fileIDx = onCleanup(@()H5F.close(fileID));
            groupID = H5G.open(fileID, pathName);
            groupIDx = onCleanup(@()H5G.close(groupID));

            names = string.empty();
            [~, ~, names] = H5A.iterate(groupID, 'H5_INDEX_NAME',...
                'H5_ITER_NATIVE', 0, @attributeIterateFcn, names);
        end

        function [x, S] = getAttributeNamesFull(fileName, pathName)
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char = '\'
            end

            if nargin == 1
                pathName = '\';
            end
            S = h5info(fileName, pathName);
            x = arrayfun(@(x) string(x.Name), S.Attributes);
        end

        function deleteAttribute(fileName, pathName, name)
            % DELETEATTRIBUTE
            %
            % Description:
            %   Delete an attribute
            %
            % Syntax:
            %   deleteAttribute(fileName, pathName, name)
            % -------------------------------------------------------------
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char
                name                char
            end

            fileID = aod.h5.HDF5.openFile(fileName);
            fileIDx = onCleanup(@()H5F.close(fileID));

            groupID = H5G.open(fileID, pathName);
            groupIDx = onCleanup(@()H5G.close(groupID));

            H5A.delete(groupID, name);
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
            if isstring(pathName)
                pathName = char(pathName);
            end

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
                attValue = attMap(k{i});
                if isenum(attValue)
                    attValue = [class(attValue), ',', char(attValue)];
                end
                if ~istext(attValue) && isSubclass(attValue, 'aod.core.Entity')
                    warning('writeatts:Skipping Entity %s', class(attValue));
                    continue
                end
                h5writeatt(fileName, pathName, k{i},...
                    aod.h5.HDF5.data2att(attValue));
            end
        end
    end

    % Link methods
    methods (Static)
        function createLink(fileName, targetPath, linkPath, linkName)
            % CREATELINK 
            %
            % Description:
            %   Creates a soft link within HDF5 file
            %
            % Syntax:
            %   createLink(fileName, targetPath, linkPath, linkName)
            % -------------------------------------------------------------
            arguments
                fileName            {mustBeFile(fileName)} 
                targetPath          char
                linkPath            char
                linkName            char
            end

            import aod.h5.HDF5
            if HDF5.exists(fileName, HDF5.buildPath(linkPath, linkName))
                warning('LinkExists: Skipped existing link at %s', linkPath);
                return
            end
            fileID = HDF5.openFile(fileName, false);
            fileIDx = onCleanup(@()H5F.close(fileID));

            linkID = H5G.open(fileID, linkPath);
            linkIDx = onCleanup(@()H5G.close(linkID));

            H5L.create_soft(targetPath, linkID, linkName, 'H5P_DEFAULT', 'H5P_DEFAULT');
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
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char
                name                char
            end

            if nargin == 2
                name = aod.h5.HDF5.getPathEnd(pathName);
                pathName = aod.h5.HDF5.getPathParent(pathName);
            end
            fileID = aod.h5.HDF5.openFile(fileName, false);
            fileIDx = onCleanup(@()H5F.close(fileID));
            if pathName == '/'
                parentID = fileID;
            else
                parentID = H5G.open(fileID, pathName);
                parentIDx = onCleanup(@()H5G.close(parentID));
            end
            H5L.delete(parentID, name, 'H5P_DEFAULT');
        end
    end

    % Data type methods
    methods (Static)
        function out = data2att(varargin)
            if nargin == 1
                data = varargin{1};
            else
                data = vertcat(varargin{:});
            end
            if islogical(data)
                out = int32(data);
            elseif isdatetime(data)
                out = datestr(data); %#ok<*DATST> 
            elseif isstring(data) && numel(data) == 1
                out = char(data);
            else
                out = data;
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
            arguments
                fileName            
                pathName            char
            end

            if isa(fileName, 'H5ML.id')
                tf = H5L.exists(fileName, pathName, 'H5P_DEFAULT');
            else
                fileID = aod.h5.HDF5.openFile(fileName, false);
                fileIDx = onCleanup(@()H5F.close(fileID));
                try
                    tf = H5L.exists(fileID, pathName, 'H5P_DEFAULT');
                catch ME
                    if contains(ME.message, 'component not found')
                        error('Parent group not found: %s', pathName);
                    else
                        rethrow(ME);
                    end
                end
            end
        end

        function x = getGroupNames(fileName, pathName)
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char = '\'
            end
            
            S = h5info(fileName, pathName);
            x = arrayfun(@(x) string(x.Name), S.Groups);
        end
        
        function x = getDatasetNames(fileName, pathName)
            arguments
                fileName            {mustBeFile(fileName)} 
                pathName            char = '\'
            end

            S = h5info(fileName, pathName);
            x = arrayfun(@(x) string(x.Name), S.Datasets);
        end
    end

    % Utility methods
    methods (Static)
        function path = buildPath(varargin)
            % BUILDPATH
            %
            % Description:
            %   Concatenates names into valid HDF5 path. If leading / is
            %   missing, it will be added
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
                path = [path, '/', char(varargin{i})]; 
            end

            % Make sure leading / isn't duplicated
            while strcmp(path(2), '/')
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
            arguments
                pathName            char
            end

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
            arguments
                pathName            char
            end

            idx = strfind(pathName, '/');
            lastName = pathName(idx(end)+1:end);
        end
    end
end 