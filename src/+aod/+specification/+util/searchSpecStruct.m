function out = searchSpecStruct(S, varargin)

    out = SearchFields(S, varargin{:});

    out(contains(out, '.Attributes.')) = [];
    out(contains(out, '.Datasets.')) = [];