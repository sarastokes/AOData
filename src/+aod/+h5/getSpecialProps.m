function specialProps = getSpecialProps()
    % GETSPECIALPROPS
    %
    % Description:
    %   Returns a list of persisted properties that are handled explicitly
    %   when writing an entity to an HDF5 file
    %
    % Syntax:
    %   specialProps = getSpecialProps()
    % ---------------------------------------------------------------------
    
    specialProps = ["Parent", "notes", "Name", "files",...
        "UUID", "description", "parameters", "Timing", "Code"];