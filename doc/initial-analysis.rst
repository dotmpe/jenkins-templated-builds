
Intro
-------
YAML maybe is the most concise syntax for human readable dict-n-lists representations.
Besides XML and JSON, it is a format of choice for configuration, and maybe metadata.

JJB provides a way to declare a build configuration in YAML. Some observations.

At the syntax level, it enables the use of YAML anchors (only within the same file) to assemble YAML objects and attributes from named YAML fragments.

JJB adds ability to use a `action macro` types, `job-group`, and/or `job-template` YAML objects to use variable substitution. Potentially enabling contruction of templated building blocks for project jobs defined, later, in other files.

There are two points to raise after using the JJB generator for a few months.

Each JJB file containing a project or job description ends up with a variable list covering all of its parts (macros and templates). The `defaults` section. It does neither seem to pick up from the original, included files' `defaults` definition and thus repeats everything.

Second, it does not allow for conditional parts. Iow. the job configuration that JJB generates is a static Jenkins XML config. Naturally that file that will not change anymore except in response to build parameters. This leaves everything but the builders section fairly static. Since only the builder section consists of exclusively customized scripts. Although there are (plugin) types that may offer scripting on other parts, such as a Groovy enabled parameter, this is the exception and not the rule.

One more minor detail worth mentioning too, is that the name of each job is tied to the template used. It will change with the template used. This seems transparent, ie. if using an extensive set of (categorized) build scripts and JJB templates, but it does tie the template to the job while there may be cases with other requirements. Ie. for OSS testing using Travis CI it is more appropiate to tie a job to a repository.

Neither issue raised seems unsurmountable. Since in the `job` or `project` definition file one has full flexibility to re-use the parts needed, and set defaults.
A job author can even choose to concatenate the files in stead of reading each separate into JJB, and have YAML anchors working across these files for a bit of extra flexibility.

Still, this is a verbose story. Even if templates are accumulated, using them and working around the above produces not only fairly detailed job descriptions, but verbose JJB files too. The first may be presumtuous, unrequired or even unfit, the latter is not preferrabke at all.
Again the former because it cannot conditional leave out bits but inherit and set everything, and the latter because it always end up with a `defaults` and a `project` object but may need a customized `job-template` too. One or more..

Ease of definition and re-use encourages the use of multiple Jenkins jobs per project,
or to think of several together as a "single build".
Which may be good or bad, YMMV.


Further details on Jenkins
---------------------------
The most principal concepts Jenkins knows about are job and builds.
Below that are all the types of parts of those two, which are quite a few.

But Jenkins has no concept of project, or of software product, or customer, that
may be used in particular applications of jenkins. Iow. all of its views are centered around the above objects. A job list and details, and a build list and details.

.. note::

    JJB does introduce the `project` object, but in my current view it can do nothing
    to really add such concept to jenkins. And maybe, it has no business here.

    JJB also uses attribute key `project-type`. Although the basic Jenkins project type 'free-style' corresponds with an ``<project />`` tag, it seems better to think of them as a Job domain object and not a Project. I hope to have outlined that in Intro_.

    This all seems a bit confused. So I'll write of Jenkis Jobs and not projects (yet). JJB does actually give a sensible map to the parts of each job.

Jenkins job type are normally free-style. This is the basic type of job, that has all the types of parts that make Jenkins so extensible:

- Triggers
- Parameters
- SCMs
- Builders
- Publishers
- Wrappers

the above are the JJB keys, which provides a good conceptual map to the dense job XML innards. Many types of plugins are available. Important here a some variations on the 'free-style' job type, and some meta-job types that only trigger other jobs.

The basic free-style job can generate a trigger for another job and so allows chaining.
For more advanced job grouping there is a job type flow, having a simple DSL to define sequential and parrallel builds of other jobs. Multijob does something similar but without a DSL.

Matrix is a plugin job type that builds all jobs of the cartesian product of several 'axis'. E.g. it could combine each branch, with each environment and build all of them.


Prelim. Charter
---------------
Leaving Jenkins and JJB, both have strengths. Jenkins diverse extensibility is particulary one of them.
Though it does not allow to build a project from a only few lines of declarations,
cf. Travis CI.

For useful CI, there is a lot of implicit assumptions about a project.
These depend on the language, the tools used, and the reports expected from a build.
Any specific build profile would depend on a set of plugins to be determined,
and have the defaults or parametrized inputs to deal with all settings.

And as for the points raised, any further conceptual requirement would simply end up as another Jenkins plugin.. I suppose.

.. sidebar:: Job URI

  For example with the name (and consequently) Uniform Location issue of the job,
  one direct solution would require to generate HTTP URL aliases and to load these into the web server io. to have control over the URLs for each job.
  Practially, one could start with a simple job to do this, and to schedule a server reload somehow. And end up with writing a plugin to do such a thing on each job.
  Maybe there is such a plugin, I did not find it.

Having YAML containing the build recipe along your project is a benefit. But if that YAML is marked by a particular set of templates then this useful data is obfuscated.

.. sidebar:: JJB

   It this case by meaningless repitition of defaults, and references to external re-usable blocks... Maybe it is a good idea, at some point in a project to start to spec the build environment(s), iow. slap versions and other tags on it. But why pretend all projects are the same..

It would be nice to loosen this coupling, or reduce it to the bare essentials.
And maybe later arrive at some 'opinionated' choices. Probably based on convention. Iow. adapt to some established use. That would help to establish something generic, like Travis CI has done. Only with Jenkins, it is not bound by a particular environment or provider. To emulated the environment though, you would need to set up a VM or container build "cloud".


Plan
-----
Some "profiles" are obiously called for, and I've planned to build the following JJB templates initially. And then see about the other issues. I fancy to set up a dockerized solution to my own PC needs more than I would setting up yet another JPI project right now.

.. note::

   These are JJB template-jobs so I use their ``{var}`` notation. Refer to the excellent `docs at OpenStack (``docs.openstack.org``)`__

  .. __: http://docs.openstack.org/infra/jenkins-job-builder


- {name}
    Not sure if this is possible. But maybe one job (URL) can serve as stepstone to its 'conceptually' related jobs. Maybe a flow job. Or a multijob stepping through predefined and customized jobs. Or only a build for a renderered representation of another flow, but itself inert without any core-project builders. Maybe it updates other jobs using JJB.

- {name}-git
    A opinionated GIT checkout job.

- {name}-git-automake
    No, no. No not really automake. But yes, make... ugh. GNU, BSD. Follow the \*NIX convention of building: ``./configure && make && make install``. And then some bits; environment, prefix(es?), isolation?


Also on the wishlist: pip, npm, bower, docker, arduino, docs (python docutils, or pandoc) and probably more.



.. Id: jtb/0.0.4-dev doc/initial-analysis.rst
