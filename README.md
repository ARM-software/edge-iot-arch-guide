
Edge IoT Architectural Design Guidelines
========================================

[to include CI runner result here]

The Edge IoT Architectural design guide is a collection of design options for developers who seek guidance on how to comply with SystemReady requirements but find overwhelming the sea of available technologies and specifications.
SystemReady is a compliance programe aiming to enable inter-operability between SoCs, hardware platforms, firmware implementations, and operating system distributions, establishing consistent boot ABIs and behaviour so that supporting new hardware platforms does not require custom engineering work.

Released "Edge IoT Architecture design guide" PDFs can be found here:

[Pointer to releases]

The latest development version is available at:


Contributing
============

Anyone may contribute to EBBR. Discussion is on the
boot-architecture@lists.linaro.org mailing list,
and there is a weekly conference call.
See CONTRIBUTING.rst_ for details.

Build Instructions
==================

Requirements
------------

* Sphinx version 1.5 or later: http://sphinx-doc.org/en/master/contents.html
* LaTeX (and pdflatex, and various LaTeX packages)
* Optionally, for verification: ``flake8``, ``mypy`` and ``yamllint``

On Debian and Ubuntu
--------------------
::

  # apt-get install python3-sphinx texlive texlive-latex-extra \
                    libalgorithm-diff-perl texlive-humanities \
                    texlive-generic-recommended texlive-generic-extra \
                    latexmk

If the version of python-sphinx installed is too old, then an additional
new version can be installed with the Python package installer::

  $ apt-get install python3-pip
  $ pip3 install --user --upgrade Sphinx
  $ export SPHINXBUILD=~/.local/bin/sphinx-build

Export SPHINXBUILD (see above) if Sphinx was installed with pip3 --user,
then follow Make commands below.

**Note**: the ``.github/workflows/main.yaml`` CI configuration file installs the
necessary dependencies for Ubuntu and can be used as an example.

On Fedora
---------

::

  # dnf install python3-sphinx texlive texlive-capt-of texlive-draftwatermark \
                texlive-fncychap texlive-framed texlive-needspace \
                texlive-tabulary texlive-titlesec texlive-upquote \
                texlive-wrapfig texinfo latexmk

On Mac OS X
-----------

* Install MacTeX_
* Install pip if you do not have it::

  $ sudo easy_install pip

* Install Sphinx::

  $ pip install --user --upgrade Sphinx

.. _MacTeX: http://tug.org/mactex

Make Targets
------------

To generate PDF::

  $ make latexpdf

To generate hierarchy of HTML pages::

  $ make html

To generate a single HTML page::

  $ make singlehtml

To generate as text (useful for comparing different versions)::

  $ make text

Output goes in ``./build`` subdirectory.

To run verifications on this repository::

  $ make check

To get some help on the available targets::

  $ make help

License
=======

This work is licensed under the Creative Commons Attribution-ShareAlike 4.0
International License (CC-BY-SA-4.0). To view a copy of this license, visit
http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

Contributions are accepted under the same with sign-off under the Developer's
Certificate of Origin. For more on contributing to EBBR, see CONTRIBUTING.rst_.

A copy of the license is included in the LICENSE_ file.

.. image:: https://i.creativecommons.org/l/by-sa/4.0/88x31.png
   :target: http://creativecommons.org/licenses/by-sa/4.0/
   :alt: Creative Commons License

.. _CONTRIBUTING.rst: ./CONTRIBUTING.rst
.. _LICENSE: ./LICENSE

Writers Guide
=============

All documentation in this repository uses reStructuredText_ markup
with Sphinx_ extensions.

All files in this project must include the relevant SPDX license identifier
tag. Generally this means each ``.rst`` file should include the line

    ``.. SPDX-License-Identifier: CC-BY-SA-4.0``

.. _reStructuredText: http://docutils.sourceforge.net/docs/user/rst/quickref.html
.. _Sphinx: http://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html

In general, try to keep the text width to at most 80 columns.
Try to write footnotes contents as close a possible to the places referencing
them.

Sphinx Extensions
-----------------

Sphinx extension files are kept under ``source/extensions/``.

Debugging extensions is easier when running Sphinx with debug messages::

  $ make singlehtml SPHINXOPTS=-vv

UEFI chapter links
^^^^^^^^^^^^^^^^^^

We have an extension for referencing UEFI specifications chapters.

To reference UEFI section 6.1 for example, write::

 :UEFI:`6.1`

This will be expanded to the following reference, with a link to the UEFI
webpage::

 UEFI § 6.1 Block Translation Table (BTT) Background

We keep the UEFI index ``.csv`` file under version control for caching, and we
have a python script to re-generate it from the UEFI specification webpage.
To re-generate the index file, do::

  $ ./scripts/update_uefi_index.py

Original Document
=================
Prior to being relicensed to CC-BY-SA 4.0, this specification was
released by Arm. The original Draft v0.5 text can be found here:

`EBBR Draft v0.5 <https://developer.arm.com/products/architecture/system-architecture/embedded-system-architecture>`_

.. SPDX-License-Identifier: CC-BY-SA-4.0
