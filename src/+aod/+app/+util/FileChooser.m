classdef FileChooser

    methods (Abstract)
        fileName = chooseFile(obj, varargin)
    end
end