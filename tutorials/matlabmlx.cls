\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{matlabmlx}[2022/11/28]

\ProcessOptions\relax
\LoadClass[11pt,letterpaper]{article}

\RequirePackage[utf8]{inputenc}
\RequirePackage[english]{babel}

% Page layout
\RequirePackage[letterpaper,margin=0.5in]{geometry}
\pagestyle{empty}

% Fonts
\RequirePackage[T1]{fontenc}
\RequirePackage[]{helvet}
\renewcommand\familydefault{\sfdefault}

% Sections
\renewcommand{\section}{%
    \@startsection
    {section}{1}{0pt}{-6pt plus -2pt minus -1pt}%
    {0.5pt plus 0.5pt minus 0.25pt}{\normalsize\bfseries}%
}
\renewcommand{\subsection}{%
 	\@startsection
 	{subsection}{2}{0pt}{-3pt plus -1pt minus -0.5pt}%
 	{0.5pt plus 0.5pt minus 0.25pt}{\normalsize\bfseries}%
 }

% Matlab's other packages
\RequirePackage{graphicx}
\RequirePackage{color}
\RequirePackage{hyperref}
\RequirePackage{amsmath}
\RequirePackage{amsfonts}
\RequirePackage{epstopdf}
\RequirePackage[table]{xcolor}
\RequirePackage{matlab}
