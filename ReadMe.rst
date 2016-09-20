Jenkins Templated Builds
========================
:Version: 0.0.4-dev
:Date: |date|
:Created: 2015-08-29
:Updated: 2016-09-20
:Description:
  JJB Templates for Jenkins
:Abstract:
  YAML's minimalism makes it very interesting for concise, generic metadata. In this particular case, to define the recipe and parameters associated with continuous integration of software |---| the contents of GIT repositories in specific.

  Presented here in this ReadMe is an short evaluation of Jenkins Job Builder [JJB] and Jenkins as a CI backend, followed by an overview of some shell and python script tooling.

:Build status:

  .. image:: https://secure.travis-ci.org/dotmpe/jenkins-templated-builds.png
    :target: https://travis-ci.org/dotmpe/jenkins-templated-builds
    :alt: Build


Docs
-----
- `Change Log <ChangeLog.rst>`_
- `Initial ReadMe <doc/initial-analysis.rst>`_


Status
------

- No tests. It either runs, or its gone
    AKA Keep cruft elsewhere.

- To (dry) run everything, find a shell: ``make update``.


.. |date| date:: %h %d. %Y
.. |time| date:: %H:%M

.. |copy| unicode:: 0xA9 .. copyright sign
.. |tm| unicode:: U+02122 .. trademark sign

.. |---| unicode:: U+02014 .. em dash
   :trim:


.. Id: jtb/0.0.4-dev ReadMe.rst
