BibSync
=======

[![Gittip donate button](http://img.shields.io/gittip/bevry.png)](https://www.gittip.com/min4d/ "Donate weekly to this project using Gittip")
[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=min4d&url=https://github.com/minad/bibsync&title=BibSync&language=&tags=github&category=software)

BibSync is a tool to synchronize your paper database with a [BibTeX](http://en.wikipedia.org/wiki/BibTeX) file which might be most
useful for Physicists and Mathematicians since it supports synchronization with [DOI](http://dx.doi.org/) and [arXiv](http://arxiv.org/).

I created this tool during the work on my diploma thesis in physics since I was unhappy
with existing tools like [Mendeley](http://www.mendeley.com/). I use this tool together with Git for version control
and [JabRef](http://jabref.sourceforge.net/) for browsing. This tool adheres more to the Unix philosophy that a small tool
for each task is better than one thing which tries to solve everything. If you use [JabRef](http://jabref.sourceforge.net/)
for browsing and tagging it is unnecessary to sort the papers into different sub directories by hand.
Just throw them all in one directory!

__Note__: This tool is derived from a script which I used during my thesis. It worked
quite well and reliable during that time. But be aware that I used Git for version control
of the [BibTeX](http://en.wikipedia.org/wiki/BibTeX) file. So any mistakes which might be made by this tool could be reverted.

Features
--------

BibSync supports the following features:

* Synchronization between a [BibTeX](http://en.wikipedia.org/wiki/BibTeX) file and a directory containing the papers in pdf, ps or djvu format
* [JabRef](http://jabref.sourceforge.net/) file fields are generated, so you can open the existing papers directly out of [JabRef](http://jabref.sourceforge.net/)
* Downloading of [arXiv](http://arxiv.org/) or [DOI](http://dx.doi.org/) metadata
* Extraction of [arXiv](http://arxiv.org/) or [DOI](http://dx.doi.org/) id out of the file using [pdftotext](http://en.wikipedia.org/wiki/Pdftotext)
* Downloading of new versions of [arXiv](http://arxiv.org/) papers
* Simple validation of [BibTeX](http://en.wikipedia.org/wiki/BibTeX) files (Checks for missing fields etc)
* Simple transformation of [BibTeX](http://en.wikipedia.org/wiki/BibTeX) fields (Normalization of author, year and journal field...)
* Works under every platform supporting Ruby and `pdftotext` (Linux, Windows, ...)

Quick start
-----------

At first you have to ensure that you have the `pdftotext` program available on your `$PATH`. Under Debian you can install
the package using `apt-get` as follows

~~~
$ apt-get install poppler-utils
$ pdftotext
pdftotext version 0.24.1
...
~~~

BibSync requires Ruby >= 1.9.2 to run. It is distributed as a RubyGems package. You can install it via
the command line

~~~
$ gem install bibsync
~~~

And for updating, you write

~~~
$ gem update bibsync
~~~

After that you can use the 'bibsync' tool on the command line. At first let's validate
a [BibTeX](http://en.wikipedia.org/wiki/BibTeX) file called 'thesis.bib'.

~~~
$ bibsync -b ~/thesis/thesis.bib
~~~

Then we want to synchronize all the papers in our paper directory with 'bibsync' and automatically download
the missing metadata.

~~~
$ bibsync -d ~/thesis/papers -b ~/thesis/thesis.bib
~~~

BibSync tries to download the metadata from [arxiv.org](http://arxiv.org) and [dx.doi.org](http://dx.doi.org). If you want to know more about the functions of 'bibsync' take a look at the command line help.

~~~
$ bibsync --help
~~~

My setup
--------

* BibSync for synchronizing
* [JabRef](http://jabref.sourceforge.net/) for browsing the bibliography, tagging and categorizing papers
* [Biblatex](http://www.ctan.org/pkg/biblatex) to include a bibliography in LaTeX with full Unicode support

Alternatives
------------

* [Mendeley](http://www.mendeley.com/) (Commercial, synchronizes with their server, limited disk space, bloated gui application)
* [Zotero](http://www.zotero.org/) (Firefox plugin, Open source)

A better name?
--------------

If you have a suggestion for a better name, just let me know...

Author
------

Daniel Mendler

License
-------

See LICENSE
