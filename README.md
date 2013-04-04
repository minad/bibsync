BibSync
=======

BibSync is a tool to synchronize your paper database with a BibTex file which might be most
useful for Physicsts and Mathematicians since it supports synchronization with DOI and arXiv.

I created this tool during the work on my diploma thesis in physics since I was unhappy
with existing tools like Mendeley. I use this tool together with Git for version control
and JabRef for browsing. This tool adheres more to the Unix philosophy that a small tool
for each task is better than one thing which tries to solve everything. If you use JabRef
for browsing and tagging it is unnecessary to sort the papers into different subdirectories by hand.
Just throw them all in one directory!

Features
--------

BibSync supports the following features:

- Synchronization between a BibLatex file and a directory containing the papers in pdf, ps or djvu format
- JabRef file fields are generated, so you can open the existing papers directly out of JabRef
- Downloading of arXiv or DOI metadata
- Extraction of arXiv or DOI id out of the file using `pdftotext'
- Downloading of new versions of arXiv papers
- Simple validation of BibLatex files (Checks for missing fields etc)
- Simple transformation of BibLatex fields (Normalization of author, year and journal field...)

Quick start
-----------

BibSync requires Ruby > 1.8.7 to run. It is distributed as a RubyGems package. You can install it via
the command line

~~~
$ gem install bibsync
~~~

After that you can use the `bibsync' tool on the command line. At first let's validate
a BibTex file called `thesis.bib'.

~~~
$ bibsync -b ~/thesis/thesis.bib
~~~

Then we want to synchronize all the papers in our paper directory with `bibsync' and automatically download
the missing metadata.

~~~
$ bibsync -d ~/thesis/papers -b ~/thesis/thesis.bib
~~~

BibSync tries to download the metadata from arxiv.org and dx.doi.org. If you want to know more
about the functions of `bibsync' take a look at the command line help.

~~~
$ bibsync --help
~~~

Alternatives
------------

* Mendeley (Commercial, synchronizes with their server, limited disk space, bloated gui application)
* Zotero (Firefox plugin, Open source)

Author
------

Daniel Mendler

License
-------

See LICENSE
