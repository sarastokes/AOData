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
            import sara.EpochTypes;
            switch obj
                case {EpochTypes.Spectral, EpochTypes.Spatial}
                    tf = true;
                otherwise
                    tf = false;
            end
        end

        function value = numChannels(obj)
            if obj == sara.EpochTypes.AnatomyOneChannel
                value = 1;
            else
                value = 2;
            end
        end
    end

    methods (Static)
        function obj = init(eType)
            if isa(eType, sara.EpochTypes)
                obj = eType;
                return 
            end

            switch lower(eType)
                case 'spectral'
                    obj = sara.EpochTypes.Spectral;
                case 'spatial'
                    obj = sara.EpochTypes.Spatial;
                case 'anatomy1'
                    obj = sara.EpochTypes.AnatomyOneChannel;
                case 'anatomy2'
                    obj = sara.EpochTypes.AnatomyTwoChannel;
                case 'unknown'
                    obj = sara.EpochTypes.Unknown;
                otherwise
                    error('Unrecognized epoch type: %s', eType);
            end
        end
    end
    
end