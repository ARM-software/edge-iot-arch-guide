# Edge IoT Architectural Design Guidelines

[to include CI runner result here]

The Edge IoT Architectural design guide is a collection of design options for developers who seek guidance on how to comply with SystemReady requirements but find overwhelming the sea of available technologies and specifications.
SystemReady is a compliance programe aiming to enable inter-operability between SoCs, hardware platforms, firmware implementations, and operating system distributions, establishing consistent boot ABIs and behaviour so that supporting new hardware platforms does not require custom engineering work.

Released "Edge IoT Architecture design guide" PDFs can be found here:

[Pointer to releases]

The latest development version is available at:


## Contributing
Anyone may contribute to Edgte IoT Architectural Design Guidelines. Discussion is on the
[TBC  SYSTEMARCHAC ] and there is a regular conference call.
See CONTRIBUTING.rst_ for details.

## Build Instructions
### Requirements

## License
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0
International License (CC-BY-SA-4.0). To view a copy of this license, visit
http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

Contributions are accepted under the same with sign-off under the Developer's
Certificate of Origin. For more on contributing to Edge IoT Achitecture Design Guide , see [CONTRIBUTING.rst][CONTRIBUTING].

A copy of the license is included in the [LICENSE][LICENSE] file.

[![Creative Commons License](https://i.creativecommons.org/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
   
[CONTRIBUTING]: ./CONTRIBUTING.rst
[LICENSE]: ./LICENSE

## Writers Guide
All documentation in this repository uses [reStructuredText][reStructuredText] markup
with [Sphinx][Sphinx] extensions.

All files in this project must include the relevant SPDX license identifier
tag. Generally this means each ``.rst`` file should include the line

 >.. SPDX-License-Identifier: CC-BY-SA-4.0

[reStructuredText]: http://docutils.sourceforge.net/docs/user/rst/quickref.html
[Sphinx]: http://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html

In general, try to keep the text width to at most 80 columns.
Try to write footnotes contents as close a possible to the places referencing
them.

### Sphinx Extensions
Sphinx extension files are kept under ``source/extensions/``.

Debugging extensions is easier when running Sphinx with debug messages::

  ``$ make singlehtml SPHINXOPTS=-vv``

