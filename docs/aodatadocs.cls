% Adapted from 'Fun Template 2', available at https://www.overleaf.com/latex/templates/fun-template-1/drwvdzsrpgzz


\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{aodatadocs}[2023/06/12]

\ProcessOptions\relax
\LoadClass[10pt]{extarticle}

\RequirePackage[english]{babel}
\RequirePackage{graphicx}
\RequirePackage{framed}
\RequirePackage[normalem]{ulem}
\RequirePackage{amsmath,amsthm,amssymb,amsfonts}
\RequirePackage{mathtools} 
\RequirePackage[nointegrals]{wasysym} 
\RequirePackage[italicdiff]{physics}
\RequirePackage[T1]{fontenc}
\RequirePackage{xparse}
\RequirePackage{xstring}
\RequirePackage{lmodern,mathrsfs}
\RequirePackage[inline,shortlabels]{enumitem}
\setlist{topsep=2pt,itemsep=2pt,parsep=0pt,partopsep=0pt}
\RequirePackage[table,dvipsnames]{xcolor}
\RequirePackage[utf8]{inputenc}
\RequirePackage{csquotes} % Must be loaded AFTER inputenc
\RequirePackage[a4paper,top=0.5in,bottom=0.2in,left=0.5in,right=0.5in,footskip=0.3in,includefoot]{geometry}
\RequirePackage[most]{tcolorbox}
\RequirePackage{multicol}
\RequirePackage[bottom,multiple]{footmisc}
\RequirePackage[colorlinks,linkcolor=.,citecolor=blue,urlcolor=violet]{hyperref}
\RequirePackage[nameinlink]{cleveref}

\newtheoremstyle{mystyle}{}{}{}{}{\sffamily\bfseries}{.}{ }{}
\makeatletter
\renewenvironment{proof}[1][\proofname] {\par\pushQED{\qed}{\normalfont\sffamily\bfseries\topsep6\p@\@plus6\p@\relax #1\@addpunct{.} }}{\popQED\endtrivlist\@endpefalse}
\makeatother
\theoremstyle{mystyle}{\newtheorem*{remark}{Remark}}
\theoremstyle{mystyle}{\newtheorem*{remarks}{Remarks}}
\theoremstyle{mystyle}{\newtheorem*{example}{Example}}
\theoremstyle{mystyle}{\newtheorem*{examples}{Examples}}
\theoremstyle{definition}{\newtheorem*{exercise}{Exercise}}

\makeatletter
\def\fsize{\dimexpr\f@size pt\relax}
\makeatother

\definecolor{tcol_DEF}{HTML}{E40125} % Color for Definition
\definecolor{tcol_LEM}{HTML}{05C4D9} % Color for Lemma
\definecolor{tcol_THM}{HTML}{1346E4} % Color for Theorem
\definecolor{tcol_REM}{HTML}{18B640} % Color for Remark
\definecolor{tcol_PRF}{HTML}{5A76B2} % Color for Proof

\tcbset{
tbox_DEF_style/.style={enhanced jigsaw,
    colback=tcol_DEF!10,colframe=tcol_DEF!80!black,,
    fonttitle=\sffamily\bfseries,
    separator sign=.,label separator={},
    sharp corners,top=2pt,bottom=2pt,left=2pt,right=2pt,
    before skip=10pt,after skip=10pt,breakable
},
tbox_THM_style/.style={enhanced jigsaw,
    colback=tcol_THM!10,colframe=tcol_THM!80!black,
    fonttitle=\sffamily\bfseries,coltitle=black,
    attach boxed title to top left={xshift=10pt,yshift=-\tcboxedtitleheight/2},
    boxed title style={
        colback=tcol_THM!10,colframe=tcol_THM!80!black,height=16pt,bean arc
    },
    separator sign=.,label separator={},
    sharp corners,top=6pt,bottom=2pt,left=2pt,right=2pt,
    before skip=10pt,after skip=10pt,breakable
},
tbox_LEM_style/.style={enhanced jigsaw,
    colback=tcol_LEM!10,colframe=tcol_LEM!80!black,
    boxrule=0pt,
    fonttitle=\sffamily\bfseries,
    attach boxed title to top left={yshift=-\tcboxedtitleheight},
    boxed title style={
        boxrule=0pt,boxsep=2pt,
        colback=tcol_LEM!80!black,colframe=tcol_LEM!80!black,
        interior code={\fill[tcol_LEM!80!black] (interior.north west)--(interior.south west)--([xshift=-2mm]interior.south east)--([xshift=2mm]interior.north east)--cycle;
    }},
    separator sign=.,label separator={},
    frame hidden,borderline north={1pt}{0pt}{tcol_LEM!80!black},
    before upper={\hspace{\tcboxedtitlewidth}},
    sharp corners,top=2pt,bottom=2pt,left=5pt,right=5pt,
    before skip=10pt,after skip=10pt,breakable
}, %separator sign none,
}

\newtcbtheorem[number within=section,
    crefname={\color{tcol_DEF!50!black} definition}{\color{tcol_DEF!50!black} definitions},
    Crefname={\color{tcol_DEF!50!black} Definition}{\color{tcol_DEF!50!black} Definitions}
    ]{definition}{Definition}{tbox_DEF_style}{}
\newtcbtheorem[use counter from=definition,
    crefname={\color{tcol_THM!50!black} theorem}{\color{tcol_THM!50!black} theorems},
    Crefname={\color{tcol_THM!50!black} Theorem}{\color{tcol_THM!50!black} Theorems}
    ]{theorem}{Theorem}{tbox_THM_style}{}
\newtcbtheorem[use counter from=definition, % no counter
    crefname={\color{tcol_LEM!50!black} lemma}{\color{tcol_LEM!50!black} lemmas},
    Crefname={\color{tcol_LEM!50!black} Lemma}{\color{tcol_LEM!50!black} Lemmas},
    ]{lemma}{}{tbox_LEM_style}{}

\makeatletter
\@namedef{tcolorboxshape@filingbox@ul}#1#2#3{
    (frame.south west)--(title.north west)--([xshift=-\dimexpr#1\relax]title.north east) to[out=0,in=180] ([xshift=\dimexpr#2\relax,yshift=\dimexpr#3\relax]title.south east)--(frame.north east)--(frame.south east)--cycle
}
\@namedef{tcolorboxshape@filingbox@uc}#1#2#3{
    (frame.south west)--(frame.north west)--([xshift=-\dimexpr#2\relax,yshift=\dimexpr#3\relax]title.south west) to[out=0,in=180] ([xshift=\dimexpr#1\relax]title.north west)--([xshift=-\dimexpr#1\relax]title.north east) to[out=0,in=180] ([xshift=\dimexpr#2\relax,yshift=\dimexpr#3\relax]title.south east)--(frame.north east)--(frame.south east)--cycle
}
\@namedef{tcolorboxshape@filingbox@ur}#1#2#3{
    (frame.south east)--(title.north east)--([xshift=\dimexpr#1\relax]title.north west) to[out=180,in=0] ([xshift=-\dimexpr#2\relax,yshift=\dimexpr#3\relax]title.south west)--(frame.north west)--(frame.south west)--cycle
}
\@namedef{tcolorboxshape@railingbox@ul}#1#2#3{
    (frame.south west)--(title.north west)--([xshift=-\dimexpr#1\relax]title.north east)--([xshift=\dimexpr#2\relax,yshift=\dimexpr#3\relax]title.south east)--(frame.north east)--(frame.south east)--cycle
}
\@namedef{tcolorboxshape@railingbox@uc}#1#2#3{
    (frame.south west)--(frame.north west)--([xshift=-\dimexpr#2\relax,yshift=\dimexpr#3\relax]title.south west)--([xshift=\dimexpr#1\relax]title.north west)--([xshift=-\dimexpr#1\relax]title.north east)--([xshift=\dimexpr#2\relax,yshift=\dimexpr#3\relax]title.south east)--(frame.north east)--(frame.south east)--cycle
}
\@namedef{tcolorboxshape@railingbox@ur}#1#2#3{
    (frame.south east)--(title.north east)--([xshift=\dimexpr#1\relax]title.north west)--([xshift=-\dimexpr#2\relax,yshift=\dimexpr#3\relax]title.south west)--(frame.north west)--(frame.south west)--cycle
}
\newcommand{\TColorBoxShape}[2]{\expandafter\ifx\csname tcolorboxshape@#1@#2\endcsname\relax
\expandafter\@gobble\else
\csname tcolorboxshape@#1@#2\expandafter\endcsname
\fi}
\makeatother

\tcbset{ % Styles for filingbox, railingbox and flagbox environments
% Adapted from https://tex.stackexchange.com/questions/587912/tcolorbox-custom-title-box-style
filingstyle/ul/.style 2 args={
    attach boxed title to top left={yshift=-2mm},
    boxed title style={empty,top=0mm,bottom=1mm,left=1mm,right=0mm},
    interior code={
        \path[fill=#1,rounded corners] \TColorBoxShape{filingbox}{ul}{9pt}{18pt}{6pt};
    },
    frame code={
        \path[draw=#2,line width=1mm,rounded corners] \TColorBoxShape{filingbox}{ul}{9pt}{18pt}{6pt};
    }},
filingstyle/uc/.style 2 args={
    attach boxed title to top center={yshift=-2mm},
    boxed title style={empty,top=0mm,bottom=1mm,left=0mm,right=0mm},
    interior code={
        \path[fill=#1,rounded corners] \TColorBoxShape{filingbox}{uc}{9pt}{18pt}{6pt};
    },
    frame code={
        \path[draw=#2,line width=0.5mm,rounded corners] \TColorBoxShape{filingbox}{uc}{9pt}{18pt}{6pt};
    }},
filingstyle/ur/.style 2 args={
    attach boxed title to top right={yshift=-2mm},
    boxed title style={empty,top=0mm,bottom=1mm,left=0mm,right=1mm},
    interior code={
        \path[fill=#1,rounded corners] \TColorBoxShape{filingbox}{ur}{9pt}{18pt}{6pt};
    },
    frame code={
        \path[draw=#2,line width=0.5mm,rounded corners] \TColorBoxShape{filingbox}{ur}{9pt}{18pt}{6pt};
    }},
railingstyle/ul/.style 2 args={
    attach boxed title to top left={yshift=-2mm},
    boxed title style={empty,top=0mm,bottom=1mm,left=1mm,right=0mm},
    interior code={
        \path[fill=#1] \TColorBoxShape{railingbox}{ul}{3pt}{12pt}{6pt};
    },
    frame code={
        \path[draw=#2,line width=0.5mm] \TColorBoxShape{railingbox}{ul}{3pt}{12pt}{6pt};
    }},
railingstyle/uc/.style 2 args={
    attach boxed title to top center={yshift=-2mm},
    boxed title style={empty,top=0mm,bottom=1mm,left=0mm,right=0mm},
    interior code={
        \path[fill=#1] \TColorBoxShape{railingbox}{uc}{3pt}{12pt}{6pt};
    },
    frame code={
        \path[draw=#2,line width=0.5mm] \TColorBoxShape{railingbox}{uc}{3pt}{12pt}{6pt};
    }},
railingstyle/ur/.style 2 args={
    attach boxed title to top right={yshift=-2mm},
    boxed title style={empty,top=0mm,bottom=1mm,left=0mm,right=1mm},
    interior code={
        \path[fill=#1] \TColorBoxShape{railingbox}{ur}{3pt}{12pt}{6pt};
    },
    frame code={
        \path[draw=#2,line width=0.5mm] \TColorBoxShape{railingbox}{ur}{3pt}{12pt}{6pt};
    }},
flagstyle/ul/.style 2 args={
    interior hidden,frame hidden,colbacktitle=#1,
    borderline west={1pt}{0pt}{#2},
    attach boxed title to top left={yshift=-8pt,yshifttext=-8pt},
    boxed title style={boxsep=3pt,boxrule=1pt,colframe=#2,sharp corners,left=4pt,right=4pt},
    bottom=0mm
    },
flagstyle/ur/.style 2 args={
    interior hidden,frame hidden,colbacktitle=#1,
    borderline east={1pt}{0pt}{#2},
    attach boxed title to top right={yshift=-8pt,yshifttext=-8pt},
    boxed title style={boxsep=3pt,boxrule=1pt,colframe=#2,sharp corners,left=4pt,right=4pt},
    bottom=0mm
    }
}
\NewTColorBox{filingbox}{ D(){ul} O{black} m O{} }{enhanced,
    top=1mm,bottom=1mm,left=1mm,right=1mm,
    title={#3},
    fonttitle=\sffamily\bfseries,
    coltitle=black,
    filingstyle/#1={#2!10}{#2},
    #4
}
\NewTColorBox{railingbox}{ D(){ul} O{black} m O{} }{enhanced,
    top=1mm,bottom=1mm,left=1mm,right=1mm,
    title={#3},
    fonttitle=\sffamily\bfseries,
    coltitle=black,
    railingstyle/#1={#2!10}{#2},
    #4
}
\NewTColorBox{flagbox}{ D(){ul} O{black} m O{} }{enhanced,breakable,
    top=1mm,bottom=1mm,left=1mm,right=1mm,
    title={#3},
    fonttitle=\sffamily\bfseries,
    coltitle=black,
    flagstyle/#1={#2!10}{#2},
    #4
}

\tcolorboxenvironment{proof}{boxrule=0pt,boxsep=0pt,blanker,
    borderline west={2pt}{0pt}{tcol_PRF},left=8pt,right=8pt,sharp corners,
    before skip=10pt,after skip=10pt,breakable
}
\tcolorboxenvironment{remark}{boxrule=0pt,boxsep=0pt,blanker,
    borderline west={2pt}{0pt}{tcol_REM},left=8pt,right=8pt,
    before skip=10pt,after skip=10pt,breakable
}
\tcolorboxenvironment{remarks}{boxrule=0pt,boxsep=0pt,blanker,
    borderline west={2pt}{0pt}{tcol_REM},left=8pt,right=8pt,
    before skip=10pt,after skip=10pt,breakable
}
\tcolorboxenvironment{example}{boxrule=0pt,boxsep=0pt,blanker,
    borderline west={2pt}{0pt}{gray5},left=8pt,right=8pt,sharp corners,
    before skip=10pt,after skip=10pt,breakable
}
\tcolorboxenvironment{examples}{boxrule=0pt,boxsep=0pt,blanker,
    borderline west={2pt}{0pt}{gray5},left=8pt,right=8pt,sharp corners,
    before skip=10pt,after skip=10pt,breakable
}

% align and align* environments with inline size
\newenvironment{talign}{\let\displaystyle\textstyle\align}{\endalign}
\newenvironment{talign*}{\let\displaystyle\textstyle\csname align*\endcsname}{\endalign}

\RequirePackage[explicit]{titlesec}
\titleformat{\section}{\fontsize{24}{30}\sffamily\bfseries}{\thesection}{20pt}{#1}
\titleformat{\subsection}{\fontsize{16}{18}\sffamily\bfseries}{\thesubsection}{12pt}{#1}
\titleformat{\subsubsection}{\fontsize{10}{12}\sffamily\large\bfseries}{\thesubsubsection}{8pt}{#1}
\titlespacing*{\section}{0pt}{5pt}{5pt}
\titlespacing*{\subsection}{0pt}{5pt}{5pt}
\titlespacing*{\subsubsection}{0pt}{5pt}{5pt}

\setlength{\parindent}{0.2in}
\setlength{\parskip}{0pt}
\setlength{\columnseprule}{0pt}

\makeatletter
% Modify spacing above and below display equations
\g@addto@macro\normalsize{
    \setlength\abovedisplayskip{3pt}
    \setlength\belowdisplayskip{3pt}
    \setlength\abovedisplayshortskip{0pt}
    \setlength\belowdisplayshortskip{0pt}
}
\makeatother

% Based on 'Fun Template 1', available at https://www.overleaf.com/latex/templates/fun-template-1/drwvdzsrpgzz
