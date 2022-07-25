classdef EpochTypes

    enumeration
        Spectral
        Spatial
        AnatomyOneChannel
        AnatomyTwoChannel
        Unknown
    end

    methods
        function tf = isPhysiology(obj)
            import patterson.EpochTypes;
            switch obj
                case {EpochTypes.Spectral, EpochTypes.Spatial}
                    tf = true;
                otherwise
                    tf = false;
            end
        end

        function value = numChannels(obj)
            if obj == patterson.EpochTypes.AnatomyOneChannel
                value = 1;
            else
                value = 2;
            end
        end
    end

    methods (Static)
        function obj = init(eType)
            if isa(eType, patterson.EpochTypes)
                obj = eType;
                return 
            end

            switch lower(eType)
                case 'spectral'
                    obj = patterson.EpochTypes.Spectral;
                case 'spatial'
                    obj = patterson.EpochTypes.Spatial;
                case 'anatomy1'
                    obj = patterson.EpochTypes.AnatomyOneChannel;
                case 'anatomy2'
                    obj = patterson.EpochTypes.AnatomyTwoChannel;
                case 'unknown'
                    obj = patterson.EpochTypes.Unknown;
                otherwise
                    error('Unrecognized epoch type: %s', eType);
            end
        end
    end
    
end