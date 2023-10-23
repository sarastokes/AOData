classdef FieldOfView < aod.builtin.calibrations.MeasurementTable  

    methods 
        function obj = FieldOfView(name, calibrationDate, varargin)
            colNames = ["Scanner", "Voltage", "FOV"];
            colUnits = ["", "V", "degrees of visual angle"];
            obj = obj@aod.builtin.calibrations.MeasurementTable(...
                name, calibrationDate, colNames, colUnits, varargin{:});
        end

        function FOV = calculate(obj, numPeaks, peakPixelRange)
            gridSpacing = obj.getAttr('GridSpacing', 'error');
            focalLength = obj.getAttr('FocalLength', 'error');
            numLines = obj.getAttr('NumLines', 'error');

            imageHalfHeight = 0.5 * numPeaks/gridSpacing;
            approxFOV = 2 * rad2deg(atan(imageHalfHeight/focalLength));
            FOV = peakPixelRange * approxFOV / numLines;
        end
    end

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.builtin.calibrations.MeasurementTable(value);

            value.set('measurements',...
                'Class', 'table', 'Description', 'FOVs per voltage per scanner');
        end

        function value = specifyAttributes()
            value = specifyAttributes@aod.builtin.calibrations.MeasurementTable();
            value.add('GridSpacing',...
                'Class', 'double', 'Size', "(1,1)", "Units", "mm",...
                "Description", "Ronchi ruling spacing");
            value.add('FocalLength',...
                'Class', 'double', 'Size', "(1,1)", "Units", "mm",...
                "Focal length of the model eye");
            value.add('NumLines',...
                'Class', 'double', 'Size', '(1,1)',...
                'Function', @mustBeInteger,...
                'Number of lines scanned');
        end
    end
end 