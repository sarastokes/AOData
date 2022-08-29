classdef Eye < aod.core.Source 
% EYE
%
% Description:
%   An eye within a Subject
%
% Parent:
%   aod.core.Source
%
% Constructor:
%   obj = Eye(name)
%
% Note:
%   Name is restricted to either 'OD' or 'OS'      
% -------------------------------------------------------------------------

    methods
        function obj = Eye(name)
            assert(ismember(name, {'OD', 'OS'}), 'Eye: Must be OS or OD');
            obj = obj@aod.core.Source(name);
        end
    end
end