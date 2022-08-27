classdef RegistrationTemplate < aod.core.Registration 
% Custom registrations must inherit from aod.core.Registration, as above

    properties
        % Any properties relevant to your registration go here
        % If you have none, delete this block
    end

    methods
        function obj = Registration(registrationDate)
            % Add additional inputs to the constructor, if needed
            obj = obj@aod.core.Registration(registrationDate);
            
            % Add custom code, if needed
        end

        function data = apply(obj, data)
            % This function must be defined, even if it is not used
            % Keep the line below if you don't need it
            error("NotImplemented");
            % If you need it, erase the line above and add your code
        end
    end
end 