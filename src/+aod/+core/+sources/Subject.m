classdef Subject < aod.core.Source 
% SUBJECT
%
% Description:
%   A mouse, human, monkey, etc
%
% Constructor:
%   obj = aod.core.sources.Subject(ID, parent)
%
% Properties:
%   ID                      Subject's identifier
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ID
    end
    
    methods 
        function obj = Subject(ID, parent)
            if nargin < 2
                parent = [];
            end

            obj@aod.core.Source(parent);
            if nargin > 0
                obj.ID = ID;
            end
        end
    end
end