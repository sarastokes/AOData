classdef SubclassGeneratorView < aod.app.UIView

    methods
        function obj = SubclassGeneratorView()
            obj@aod.app.UIView();
        end
    end

    methods
        function obj = createUi(obj)

            % What should the entity be named?
            % > uieditfield (#1)

            % Where will the entity be saved?
            % > uigetdir (#2), check file conflicts
            
            % Which EntityType?
            % > uidropdown (#3)
            
            % What is the parent class?
            % > uidropdown (#4) based on entityType, then show inherited

            % What datasets should the entity have (properties)?
            % - Required: name
            %   > uieditfield
            % - Optional: class, default
            %   > uieditfield, uieditfield
            % - Optional: Property's importance - required, optional or N/A
            %   > uidropdown (default N/A)

            % What links should the entity have (properties)?
            % - Required: Name 
            %   > uieditfield
            % - Optional: entityType(s)
            %   > uidropdown (excluding Experiment, Parent & EntityType)

            % What attributes are expected?
            % - Required: Name 
            %   > uieditbox
            % - Optional: default, validation
            %   > uieditbox, uieditbox
            % - Optional: importance - required, optional or N/A
            %   > uidropdown (default N/A)

            % How should the entity's group name be determined?
            % - User defined?
            % - Hard-coded default? Could still be changed with setName
            %   - What is the default?
            % - Automated based on properties/attributes?
            %   - Remove name input to constructor?

            % Any specifications on inherited methods?
            % - Overloaded methods?
            %   > uidropdown
            % - Overwritten methods?
            %   > uidropdown
        end
    end
end 