# Global latexmk configuration for modern LaTeX compilation

# Use LuaLaTeX by default for Unicode and modern font support
$pdf_mode = 4;  # 4 = lualatex, 5 = xelatex
$dvi_mode = 0;
$postscript_mode = 0;

# Use biber for bibliography (modern replacement for bibtex)
$bibtex_use = 2;  # 2 = biber

# Continuous preview settings
# Note: VimTeX handles continuous preview mode, so disable it here
# to prevent multiple processes racing and corrupting .aux files
$preview_continuous_mode = 0;
$pdf_previewer = 'open -a Skim';

# Clean up auxiliary files
$clean_ext = 'synctex.gz synctex.gz(busy) run.xml tex.bak bbl bcf fdb_latexmk aux log blg brf fls idx ilg ind lof lot out toc';

# Custom dependency handling for glossaries
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
  if ( $silent ) {
    system "makeglossaries -q '$_[0]'";
  }
  else {
    system "makeglossaries '$_[0]'";
  };
}

# Ensure synctex is enabled
$lualatex = 'lualatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
$xelatex = 'xelatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';