classdef DefaultFileChooser < aod.app.util.FileChooser
% Wrapper for uigetfile for use with testsuite

    methods
        function fileName = chooseFile(~, ext, title)
            if nargin < 2
                ext = [];
            end
            if nargin < 3
                title = pwd();
            end
            fileName = uigetfile(ext, title,...
                'MultiSelect', 'on');
            if fileName == 0
                fileName = [];
            end
        end
    end
end