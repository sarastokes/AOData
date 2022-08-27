classdef Creator < aod.core.Creator

    methods
        function obj = Creator(experiment)
            obj@aod.core.Creator(experiment);
        end

        function addRigidTransform(obj, fName, epochIDs, varargin)
            % ADDRIGIDTRANSFORM
            %
            % Syntax:
            %   obj.addRigidTransform(fName, epochIDs, varargin)
            % -------------------------------------------------------------
            if ~isfile(fName)
                fName = fullfile(obj.Experiment.getAnalysisFolder(), fName);
            end
            reader = aod.builtin.readers.RigidTransformReader(fName);
            tforms = reader.read();

            for i = 1:numel(epochIDs)
                ep = obj.Experiment.id2epoch(epochIDs(i));
                reg = aod.builtin.registrations.RigidRegistration(...
                    ep, squeeze(tforms(:,:,i)), varargin{:});
                ep.addRegistration(reg);
                ep.setFile('SiftTransform', erase(fName, obj.homeDirectory));
            end
        end
    end
end