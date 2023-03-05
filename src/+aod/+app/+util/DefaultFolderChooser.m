classdef DefaultFolderChooser < aod.app.util.FolderChooser
% Wrapper for uigetfile for use with testsuite

    methods 
        function folderName = chooseFolder(~, title, startPath)
            if nargin < 2
                title = [];
            end
            if nargin < 3
                startPath = pwd();
            end
            folderName = uigetdir(startPath, title);
            if folderName == 0
                folderName = [];
            end 
        end
    end
end