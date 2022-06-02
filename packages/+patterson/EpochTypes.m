classdef EpochTypes

    enumeration
        Spectral
        Spatial
        Anatomy
        Unknown
    end

    methods
        function tf = isPhysiology(obj)
            if obj == patterson.EpochTypes.Spectral || obj == patterson.EpochTypes.Spatial
                tf = true;
            else
                tf = false;
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
                case 'anatomy'
                    obj = patterson.EpochTypes.Anatomy;
                case 'unknown'
                    obj = patterson.EpochTypes.Unknown;
                otherwise
                    error('Unrecognized epoch type: %s', eType);
            end
        end
    end
    
end