.. include:: .default.rst

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

  YAML supports custom entities ('anchors'), which make re-use of template parts
  even more easy. But for dynamic templates, or parts there is no solution other
  than taking another step back.

  Presented here was a short evaluation of Jenkins Job Builder [JJB] and Jenkins as a CI backend, followed by an introduction of some shell and python script tooling.



:Build status:
  .. image:: https://secure.travis-ci.org/dotmpe/jenkins-templated-builds.png
    :target: https://travis-ci.org/dotmpe/jenkins-templated-builds
    :alt: Build


Docs
-----
- `Change Log <ChangeLog.rst>`_
- `Initial ReadMe <doc/initial-analysis.rst>`_


Intro
------
Some old docs referred to above provide a generic overview. To get started,
see ``tpl/`` and the JJB in YAML parts there, and ``preset/*.yml`` for the kind
of definitions that JTB provides.

Read the source and tooling for details.

make dist
  Recompile ``tpl/`` to ``dist/base.yaml``.

make test
  CI test script that among other things tests all JTB files in ``preset/*.yml``
  by compiling them and testing with JJB.

make update
  To (dry) run everything with JJB, find a shell: ``make update FILES=JJB_FILE:JJB_FILE...``.
  This deferes to ``bin/jtb.sh`` (jtb-sh_) and by defaults uses ``jtb.yaml``.

jtb-sh_ and jtb-py_ are not documented.


Issues
------
JTB-1 Task: improved placeholder expansion from env.
  (D) Current environment expansion has the downside that placeholders need
  to be present in the template. This is not always wanted or feasible. It
  requires to have a default value, and for e.g. 'workspace'
  that is just too complex. Normal names would be OK, but with CloudBees Folders
  we would need to insert the Path and URL equivalents for the name into the
  templater too.

  As a workaround, perhaps enable an insert-into-JTB mode for options/env.

JTB-2 FIXME: build fails b/c hidden parameter not supported
  (C) 2017-03-29 Build is failing b/c hidden parameter not supported by my JJB install @1.6.2

JTB-3 BUG: expanding object values fails with hyphened key names
  Variable name handling does require some 'my_id' to 'my-id' conversion. This has
  not been an issue, but other related issue is that JJB itself does not like
  (1.6.2) objects in keys containing hyphens. Iow. the following does not work, but
  it does when renamed to 'blocking_builds'
  ::

    blocking-builds:
      - build1.*
      - build2.*
    ...
    blocking-builds: '{obj:blocking-builds}'

  (also booleans are objects but other simples are not?)

Other issues in `Dev Docs`_ and `todo list`.



.. Id: jtb/0.0.4-dev ReadMe.rst
