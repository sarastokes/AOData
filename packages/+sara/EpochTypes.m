classdef EpochTypes

    enumeration
        SPECTRAL
        SPATIAL
        ANATOMYONECHANNEL
        ANATOMYTWOCHANNEL
        BACKGROUND
    end

    methods
        function tf = isPhysiology(obj)
            import sara.EpochTypes;
            switch obj
                case {EpochTypes.SPECTRAL, EpochTypes.SPATIAL}
                    tf = true;
                otherwise
                    tf = false;
            end
        end

        function value = numChannels(obj)
            if obj == sara.EpochTypes.ANATOMYONECHANNEL
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
                    obj = sara.EpochTypes.SPECTRAL;
                case 'spatial'
                    obj = sara.EpochTypes.SPATIAL;
                case 'anatomy1'
                    obj = sara.EpochTypes.ANATOMYONECHANNEL;
                case 'anatomy2'
                    obj = sara.EpochTypes.ANATOMYTWOCHANNEL;
                case 'backgroumd'
                    obj = sara.EpochTypes.BACKGROUND;
                otherwise
                    error('Unrecognized epoch type: %s', eType);
            end
        end
    end
    
end