function writeEntitySchema(hdfName, hdfPath, schema)
% WRITEENTITYSCHEMA
%
% Syntax:
%   aod.h5.writeEntitySchema(hdfName, hdfPath, schema)
%
% Inputs:
%   hdfName             HDF5 file name and path
%   hdfPath             Path to group to write dataset containing schema
%   schema              aod.schema.EntitySchema

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        hdfName             {mustBeHdfFile(hdfName)}
        hdfPath             char
        schema              aod.schema.EntitySchema
    end

    % TODO: Read from persisted file or use jsonencode?
    % TODO: Shouldn't be recreating the struct each time a class is written
    %       Instead explore caching the results of struct calls after 
    %       testing the time cost of recreating struct (seems fast)
    h5tools.write(hdfName, hdfPath, 'Schema', jsonencode(schema.struct()));
    h5tools.writeatt(hdfName, h5tools.util.buildPath(hdfPath, 'Schema'),...
        'DatasetCount', schema.Datasets.Count,...
        'AttributeCount', schema.Attributes.Count,...
        'FileCount', schema.Files.Count);

    % THOROUGH BUT WAY TO COMPLICATED AND SLOW
    % % Create the group
    % h5tools.createGroup(hdfName, hdfPath, 'Schema');
    % schemaPath = h5tools.util.buildPath(hdfPath, 'Schema');

    % % Create the subgroups
    % h5tools.createGroup(hdfName, schemaPath, 'Datasets');
    % h5tools.createGroup(hdfName, schemaPath, 'Attributes');
    % h5tools.createGroup(hdfName, schemaPath, 'Files');

    % dsetsPath = h5tools.util.buildPath(schemaPath, 'Datasets');
    % dsetCollection = schema.Datasets;
    % attrsPath = h5tools.util.buildPath(schemaPath, 'Attributes');
    % filesPath = h5tools.util.buildPath(schemaPath, 'Files');

    % % Write the datasets
    % for i = 1:dsetCollection.Count
    %     record = dsetCollection.Records(i);
    %     h5tools.createGroup(hdfName, dsetsPath, record.Name);
    %     recordPath = h5tools.util.buildPath(dsetsPath, record.Name);
    %     [validators, decorators] = aod.schema.util.getValidatorsAndDecorators(record);
    %     for i = 1:numel(validators)
    %         h5tools.write(hdfName, recordPath, validators(i), p.Value);
    %     end
    % end