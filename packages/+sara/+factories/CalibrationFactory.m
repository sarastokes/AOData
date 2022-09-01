classdef CalibrationFactory < aod.util.Factory

    methods
        function obj = CalibrationFactory()
        end

        function cal = get(obj, name, calibrationDate)
            switch name 
                case 'MaxwellianView'
                    cal = sara.calibrations.MaxwellianView(date); 
                    if strcmp(date, '20220727')
                        cal.assignUUID("099855e6-50b1-4d0d-a953-b7f6b8df0d0e");
                    elseif strcmp(date, '20220314')
                        cal.assignUUID("82f9d996-11f5-41ab-8736-253c83003cde");
                    end         
                case 'TopticaNonlinearity'
                    cal = sara.calibrations.TopticaNonlinearity(561, '20210801');
                    cal.assignUUID("e5a2a93e-2f3b-4e77-a462-c5ad43f18224");
                otherwise
                    error("CalibrationFactory:UnregisteredCalibration",...
                        "Calibration %s not supported by factory", date);
            end
        end
    end

    methods (Static)
        function cal = create(name, calibrationDate)
            obj = sara.factories.CalibrationFactory;
            cal = obj.get(name, calibrationDate);
        end
    end
end 