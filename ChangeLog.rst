0.0.1
  - Initial templates with Travis build to test with jenkins-job-builder.
  - branch r0.0.1 was never integrated with main as it used inline
    versions in a peculiar way. And 0.0.1 continued for some time.

0.0.2
  - Split up templates, with YAML aliases spread across and compiling into
    destination using simple include sentinel markers processed by a sh script.
  - Many updates on the JJB templates.
  - Added python program to handle compiling JJB templates from a new non-JJB YAML structure.
    Attempting to support generating jobs for other projects, see preset/ directory.

(0.0.3)
  - Cleaned up the script and doc structure a bit, moving things to separate
    subdirs.

  - TODO: Improve jtb preset flexibiity. See about some way to wizards and
    guided interactive setups and deal with more and more build options.

  - Documenting commands.

  - BUG: raw travis XML is no longer accepted (Jenkins 2.0). The builder
    must be added by hand.


.. Id: jtb/0.0.3-dev ChangeLog.rst
