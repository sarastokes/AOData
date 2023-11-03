classdef TextTable < handle
% TEXTTABLE     Generate an ASCII table.
%
% TEXTTABLE('Property1',PropVal1,'Property2',PropVal2,...) creates TextTable
%           with specified properties. Available properties:
%       
%       Corner          Character used at corner points
%       Delimiter       Cell Array (1x6) to specify border styles
%       Text_Wrap       Boolean to specify if text should wrap lines
%
%
%
%           Corner--> +---------------------------------+ <--Corner
%     delimiter{1}--> |          Example Table<---------|--Table Title
%                     ===================================
%                     |  Col 1   |   Col 2   |  Col 3   | <--Column Titles
%                     ===================================
%                     |The tex...|           |          |
%                     |t will ...|           |          |
%                     |   wrap   |Column fit |   N/A    | <-- delimiter{3}
%                     -----------------------------------
%                     |Col1,Row2 | Col3,Row2 | <--------|-- delimiter{2}
%                     +---------------------------------+
%
% t = TEXTTABLE();
% t.table_title = '' sets the property which determines the display of the table title.
%                    Empty strings removes title
%
% t.addColumns( { 'Column 1 Name', 'Column 2 Name', ... }, [ *Column Width Array* ], ...
%                     [ *Justification Array* ] );
% 
%                 |-> Columns names must be cell array of character arrays
%     
%                 |-> [ *Columns Width Array*] is an array matching the size of the column
%                     names array. The numeric value specifies the width of the columns in
%                     standard ASCII character widths. A value of -1 will automatically match
%                     the width of the column to the longest string within that column
%     
%                 |-> [ *Justification Array*] is an array matching the size of the column
%                     names array. The numeric value of each entry can be 1,2,3:
%                 |---------> Left Justification: 1
%                 |---------> Middle Justification: 2
%                 |---------> Right Justification: 3
%
% t.addRows( { 'Row1,Col1 Data', 'Row1,Col2 Data', ...; 'Row2,Col1 Data, 'Row2,Col2 Data', ... }, ...
%            { *R1C1 RGB*, *R1C2 RGB*, ...; *R2C1 RGB*, *R2C2 RGB*, ... } );
%                 |-> Data must have the save width as the number of columns specified above
%
%                 |-> Cell array of RGB triples specifies color, must be the same size as data cell array
%
%   ***NOTE: In order to use the color print option, the function cprintf() must be avialable.
%            This is a very useful function written by Yair Altman and provided through Matlab File Exchange***
%
%
% str = t.print( DISPLAY, USE_COLOR ) generates the specified table into the str variable as
%       as a character array. DISPLAY determines if the the function should directly output to STDOUT.
%       USE_COLOR utilizes cprintf to print in color to STDOUT. If DISPLAY is false, printing in
%       color is not available.
%
%% Example Usage
% Creating the table above (wihtout annotations)
% t = TextTable();
% t.table_title = 'Example Table';
% t.addColumns( { 'Col 1', 'Col 2', 'Col 3' }, [ 10 -1 -1 ], [ 2 2 2 ] );
% t.addRows( { 'The text will wrap', 'Column fit', 'N/A'; 'Col1,Row2', 'Col2,Row2', '' } );
% t.text_wrap = true;
% s = t.print( true, false );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        col_headers = {};
        row_widths = [];
        text_wrap = false;
        row_data = {};
        delimiter = {};
        table_title = [];
        fmts = [];
        corner = [];
        row_colors = {};
        base_col = [ 0 0 0 ];
    end
    
    methods
        function o = TextTable( varargin )
            p = inputParser;
            addParameter( p, 'corner', '+', @ischar );
            addParameter( p, 'delimiter', { '|', '|', '|', '=', '-' }, @(x)( iscell(x) && numel(x)==5 && ischar(x{1}) ) );
            addParameter( p, 'text_wrap', false, @islogical );
            parse( p, varargin{:} );
            
            o.delimiter = p.Results.delimiter;
            o.corner = p.Results.corner;
            o.text_wrap = p.Results.text_wrap;
        end
        
        function addColumns( o, nm, wds, fmts )
            arguments
                o TextTable
                nm cell
                wds double = []
                fmts double = []
            end
            
            if( isempty( wds ) )
                wds = -1 * ones( numel( nm ), 1 );
            end
            
            if( isempty( fmts ) )
                fmts = ones( numel( nm ), 1 );
            end
            
            assert( numel( nm ) == numel( wds ) );
            assert( numel( nm ) == numel( fmts ) );
            
            for i = 1:numel( nm )
                o.col_headers{end+1} = nm{i};
                if( wds(i) < 4 && wds(i) ~= -1 ), wds(i) = 4; end
                o.row_widths = [ o.row_widths, wds(i) ];
                o.fmts = [ o.fmts, fmts(i) ];
            end
        end
        
        function addRow( o, row, colors )
            arguments
                o TextTable
                row cell
                colors double = [ 0 0 0 ];
            end
            
            assert( isrow(row) );
            assert( sum( size(colors)==[1,3] )==2 );
            o.row_data{end+1} = row;
            o.row_colors{end+1} = colors;
        end
        
        function addRows( o, rows, colors )
            arguments
                o TextTable
                rows cell
                colors double = []
            end
            
            if( isempty( colors ) )
                colors = zeros( size( rows, 1 ), 3 );
            end
            
            for i = 1:size( rows, 1 )
                o.addRow( { rows{i,:} }, colors(i,:) );
            end
        end
        
        function s = print( o, display, display_color )
            arguments
                o TextTable
                display logical = true
                display_color logical = true
            end
            
            if( ~display )
                tmp_base_col = o.base_col;
                o.base_col = -1;
            end
            
            if( ~display_color || ~display )
                tmp_cols = o.row_colors;
                [ o.row_colors{1:numel(tmp_cols)} ] = deal( o.base_col ); 
            end
            
            s = [];
            % get column length
            col_lens = zeros( numel( o.col_headers ), 1 );
            for i = 1:numel( col_lens )
                if( o.row_widths(i) == -1 )
                    col_lens(i) = o.maxLengthInColumn( i )+1;
                else
                    col_lens(i) = o.row_widths(i);
                end
            end
            
            % make sure everything lines up
            s = [ s, TextTable.printf( '%s%s%s\n', o.corner, repmat( o.delimiter{5}, sum( col_lens ) -1 + numel( o.col_headers ), 1 ), o.corner, 'color', o.base_col ) ];
            tmp = o.fmts;
            o.fmts = 2; % hackey to center the title
            s = [ s o.println( -1, sum( col_lens )+2 ) ];
            o.fmts = tmp;
            
            s = [ s, TextTable.printf( '%s\n', repmat( o.delimiter{4}, sum( col_lens ) + 1 + numel( o.col_headers ), 1 ), 'color', o.base_col ) ];
            s = [ s, o.println( 0, col_lens ) ];
            s = [ s, TextTable.printf( '%s\n', repmat( o.delimiter{4}, sum( col_lens ) + 1 + numel( o.col_headers ), 1 ), 'color', o.base_col ) ];
            
            for i = 1:numel( o.row_data )-1
                s = [ s, o.println( i, col_lens ) ];
                s = [ s, TextTable.printf( '%s\n', repmat( o.delimiter{5}, sum( col_lens ) + 1 + numel( o.col_headers ), 1 ), 'color', o.row_colors{i} ) ];
            end
            i = i + 1;
            if( isempty( i ) ), i=1; end
            s = [ s, o.println( i, col_lens ) ];
            
            s = [ s, TextTable.printf( '%s%s%s\n', o.corner, repmat( o.delimiter{5}, sum( col_lens ) -1 + numel( o.col_headers ), 1 ), o.corner, 'color', o.base_col ) ];
            
            if( ~display )
                o.base_col = tmp_base_col;
            end
            
            if( ~display_color || ~display )
                o.row_colors = tmp_cols;
            end
        end
    end
    
    methods ( Access = private )
        function s = println( o, line, wd )
            s = [];
            entries = {};
            col = [];
            if( line == 0 ) % headers
                entries = cell( numel( o.col_headers ), 1 );
                for i = 1:numel( entries )
                    entries{i} = o.lineWrap( o.col_headers{i}, wd(i) );
                end
                col = o.base_col;
            elseif( line == -1 ) % table title
                if( isempty( o.table_title ) ), return; end
                entries{end+1} = o.lineWrap( o.table_title, wd );
                col = o.base_col;
            else
                entries = cell( numel( o.col_headers ), 1 );
                for i = 1:numel( entries )
                    entries{i} = o.lineWrap( o.row_data{line}{i}, wd(i) ); 
                end
                col = o.row_colors{line};
            end
            
            % get largest required text wrap for line
            h = 0;
            for i = 1:numel( entries )
                tmp = numel( entries{i} );
                if( tmp > h )
                    h = tmp;
                end
            end
            
            % buffer entries which didn't require as much line wrapping
            for i = 1:numel( entries )
                tmp = numel( entries{i} );
                if( tmp < h )
                    entries{i} = flip( entries{i}, 2 );
                    for j = 1:(h-tmp)
                        entries{i}{end+1} = ' ';
                    end
                    entries{i} = flip( entries{i}, 2 );
                end
            end
            
            for i = 1:h
                s = [ s, TextTable.printf( '%s', o.delimiter{1}, 'color', col ) ];
                for j = 1:numel( entries )
                    s = [ s, o.printColEntry( entries{j}{i}, o.fmts(j), wd(j), col ) ];
                end
                s = [ s, TextTable.printf( '\b%s\n', o.delimiter{3}, 'color', col ) ];
            end
        end
        
        function s = printColEntry( o, str, fmt, wd, col )
            s = [];
            strl = strlength( str );
            assert( strl <= wd );
            assert( sum( size( col )==[1,3] )==2 || numel( col )==1 );
            
            rem = wd - strl;
            
            buf = {};
            if( fmt == 1 || fmt == 3 )
                buf{1} = repmat( ' ', rem, 1 );
                if( fmt == 1 )
                    s = [ s, TextTable.printf( '%s%s%s', buf{1}, str, o.delimiter{2}, 'color', col ) ];
                else
                    s = [ s, TextTable.printf( '%s%s%s', str, buf{1}, o.delimiter{2}, 'color', col ) ];
                end
            elseif( fmt == 2 )
                buf{1} = repmat( ' ', floor( rem/2 ), 1 );
                buf{2} = repmat( ' ', ceil( rem/2 ), 1 );
                s = [ s, TextTable.printf( '%s%s%s%s', buf{1}, str, buf{2}, o.delimiter{2}, 'color', col ) ];
            else
                error( 'ERROR [TextTable->(p)printColEntry]: Format unrecognized' );
            end
        end
        
        function ml = maxLengthInColumn( o, col )
            assert( numel( o.col_headers ) > 0, 'ERROR [TextTable->(p)maxLengthInColumn]: No column headers defined' );
            %ml = max( strlength( o.col_headers ) );
            ml = max(cellfun(@strlength, o.col_headers));
            for i = 1:size( o.row_data, 2 )
                assert( numel( o.row_data{i} ) >= col, sprintf('ERROR [TextTable->(p)maxLengthInColumn]: Short row{%d}', i ) );
                tmp = strlength( o.row_data{i}{col} );
                if( tmp > ml )
                    ml = tmp;
                end
            end
        end
        
        function [ wrp ] = lineWrap( o, str, wd )
            arguments
                o
                str         char
                wd
            end
            assert( ischar( str ), 'ERROR [TextTable->(p)lineWrap]: Input must be char' );
            assert( sum( any( wd < 4 ) )==0, 'ERROR [TextTable->(p)lineWrap]: Width must be at least 4' );
            strl = strlength( str );
            if( wd == -1 || strl <= wd || strl == 0 )
                wrp = { str };
            else
                if( ~o.text_wrap )
                    wrp = cell( 1,1 );
                    wrp{1} = sprintf( '%s...', str( 1:(wd-3) ) );
                else
                    wrp = cell( ceil( strl / ( wd-3 ) ), 1 );
                    for i = 1:(numel( wrp )-1)
                        wrp{i} = sprintf( '%s...', str( ((i-1)*(wd-3)+1):((i)*(wd-3)) ) );
                    end
                    i = i + 1;
                    wrp{i} = sprintf( '%s', str( ((i-1)*(wd-3)+1):strl ) );
                end
            end
        end
    end
    
    methods ( Static )
        function s = printf( fmt, varargin )
            s = [];
            c = -1;
            color_specified = false;
            if( nargin > 2 )
                if( strcmpi( varargin{nargin-2}, 'color' ) )
                    c = varargin{nargin-1};
                    color_specified = true;
                end
            end
            
            if( c == -1 )
                if( color_specified )
                    s = sprintf( fmt, varargin{1:end-2} );
                else
                    s = sprintf( fmt, varargin{:} );
                end
            elseif( isempty( c ) )
                fprintf( fmt, varargin{1:end-2} );
                s = sprintf( fmt, varargin{1:end-2} );
            else
                cprintf( c, fmt, varargin{1:end-2} );
                s = sprintf( fmt, varargin{1:end-2} );
            end
        end
    end
    
end