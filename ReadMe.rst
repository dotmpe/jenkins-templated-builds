Jenkins Templated Builds
========================
:Version: 0.0.4-dev
:Date: |date|
:Description:
  JJB Templates for Jenkins
:Abstract:
  YAML's minimalism makes it very interesting for concise, generic metadata. In this particular case, to define the recipe and parameters associated with continious integration of software |---| the contents of GIT repositories in specific.

  Presented here in this ReadMe is an short evaluation of Jenkins Job Builder [JJB] and Jenkins as a CI backend, followed by an overview of some initial work contained within this project.

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
    Well there is a test branch now.

- To run, find a shell: ``./update``.

- Using with dockerized jenkins (git@github.com:dotmpe/docker-jenkins.git v0.0.1).

  This job will actually update itself right now.


TODO: make better use of groovy extensions. https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+Script+Console

Scriptler? https://wiki.jenkins-ci.org/display/JENKINS/Scriptler+Plugin

- .jenkins.yml research and thoughts [2014] https://gist.github.com/christianchristensen/5519757



.. |date| date:: %h %d. %Y
.. |time| date:: %H:%M

.. |copy| unicode:: 0xA9 .. copyright sign
.. |tm| unicode:: U+02122 .. trademark sign

.. |---| unicode:: U+02014 .. em dash
   :trim:


.. Id: jtb/0.0.4-dev ReadMe.rst
