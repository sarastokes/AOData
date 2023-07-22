classdef TestFactory < aod.util.Factory 
% Factory class without create implementation

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    methods 
        function obj = TestFactory()
            % Do nothing
        end

        function newObj = get(~, varargin)
            newObj = 123;
        end
    end
end 