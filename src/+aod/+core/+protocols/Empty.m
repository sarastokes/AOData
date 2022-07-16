classdef Empty < aod.core.Protocol
% EMPTY
%
% Description:
%   A placeholder protocol used when specific protocol can't be created
%
% Parent:
%   aod.core.Protocol
%
% Constructor:
%   obj = Empty(varargin)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        sampleRate = 1
        stimRate = 1
    end

    methods 
        function obj = Empty(varargin)
            obj = obj@aod.core.Protocol(varargin{:});
        end

        function stim = generate(obj) %#ok<MANU> 
            stim = [];
        end

        function fName = getFileName(obj) %#ok<MANU> 
            fName = [];
        end

        function writeStim(obj, fName) %#ok<INUSD> 
            error('Not implemented');
        end
    end
end 