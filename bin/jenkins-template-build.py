#!/usr/bin/env python
"""

Helper to find template from files, return placeholders,
and generate new job definition using template.

Commands:

    vars <template-id> [<jjb-yaml-file>..]

    generate <template-id> [<jjb-yaml-file>..]

    preset <preset-id> [<jjb-yaml-file>..]

"""
import os
import re
import sys

import yaml


version = '0.0.3-dev' # jtb

def get_template(path, jjb_template_id):

    try:
        base = yaml.load(open(path))
    except Exception, e:
        raise Exception("Failed loading %s: %s. %s" % (jjb_template_id, path, str(e)))

    for item in base:
        if 'job-template' in item:
            if item['job-template']['name'] == jjb_template_id:
                return item['job-template']


def get_preset(path):

    base = yaml.load(open(path))
    assert len(base[0].keys()) == 1
    return base[0].items()[0]


block_keys = "name parameters properties triggers scm builders publishers wrappers axes".split(' ')

def get_defaults(path, keys, jjb_template_id):

    r = {}
    base = yaml.load(open(path))

    for item in base:
        if 'defaults' in item:
            d = dict(item['defaults'])
            del d['name']
            r.update(d)

    for item in base:
        if 'job-template' in item:
            d = item['job-template']
            for k in d.keys():
                if k == 'name':
                    continue
                if k in keys:
                    r[k] = d[k]

    return r


re_var = re.compile('\{+[A-Za-z0-9_\.\:-]+\}+')

def find_template_vars_str(st):

    m = re_var.findall(st)
    if isinstance(m, list) and m:
        for i in m:
            if i.startswith('{{'):
                continue
            if i.startswith('{obj:'):
                yield i[5:-1]
            else:
                yield i[1:-1]

def find_template_vars_list(ls):

    for i in ls:
        g = None

        if isinstance(i, list):
            g = find_template_vars_list(i)

        elif isinstance(i, (bool, float, int)):
            pass

        elif isinstance(i, basestring):
            g = find_template_vars_str(i)

        elif i and isinstance(i, object):
            g = find_template_vars(i)

        if g:
            for y in g:
                if y: yield y

def find_template_vars(obj):

    assert hasattr(obj, 'keys'), "No object: %s" % obj
    for x in obj.keys():
        g = None

        if isinstance(obj[x], list):
            g = find_template_vars_list(obj[x])

        elif isinstance(obj[x], (bool, float, int)):
            pass

        elif isinstance(obj[x], basestring):
            g = find_template_vars_str(obj[x])

        elif obj[x] and isinstance(obj[x], object):
            g = find_template_vars(obj[x])

        if g:
            for y in g:
                if y: yield y


def format_job(jjb_template_id, vars):

    """
    Given template ID and placeholder values, generate a YAML file
    that defines a Jenkins job by specifying a JJB 'project' object with one
    templated jobs.
    """

    assert vars['name'], "At least {name} is required"

    name = vars['name']
    del vars['name']

    for key in block_keys:
        if key in vars:
            if isinstance(vars[key], basestring) and vars[key].startswith('{obj:'):
            	vars[key] = {}
            else:
            	del vars[key]

    jjb_tpld_job = [ { 'project': {
        'name': name,
        'jobs': [ { jjb_template_id: vars } ]
    } } ]

    return yaml.dump(jjb_tpld_job, default_flow_style=False)



def find_template(jjb_template_id, *template_files):
    for path in template_files:
        template = get_template(path, jjb_template_id)
        if not template:
            raise Exception("No template with name %s" % jjb_template_id)

    print '# Found', jjb_template_id, 'in', path
    return path, template


def run_vars(jjb_template_id, *template_files):

    """
    Show the JJB placeholders for template ID that have no default values.
    """

    path, template = find_template(jjb_template_id, *template_files)
    placeholders = list(set(find_template_vars(template)))
    seed = dict( zip(placeholders, ( [None] * len(placeholders) )) )
    defaults = get_defaults(path, placeholders, jjb_template_id)

    for key in placeholders:
        seed[key] = os.getenv(key, defaults.get(key, None))

    for key in placeholders:
        print key, seed.get(key, None)


def generate_job(jjb_template_id, *template_files):

    path, template = find_template(jjb_template_id, *template_files)
    placeholders = list(set(find_template_vars(template)))
    defaults = get_defaults(path, placeholders, jjb_template_id)

    return placeholders, defaults


def run_generate(jjb_template_id, *template_files):

    """
    Generate JJB config by loading given job-template ID, and resolving
    the placeholders from variables in the shell environment.
    """

    placeholders, defaults = generate_job(jjb_template_id, *template_files)
    seed = dict( zip(placeholders, ( [None] * len(placeholders) )) )

    for key in placeholders:
        seed[key] = os.getenv(key, defaults.get(key, None))
        # TODO: parse some block stuff?
        if key in block_keys and not seed[key]:
            seed[key] = {}

    print format_job(jjb_template_id, seed)


def run_preset(preset_file, *template_files):

    """
    Generate a job using job-template ID like 'generate', except load
    the template ID, name and default values from YAML preset file.
    """

    jjb_template_id, seed = get_preset(preset_file)

    placeholders, defaults = generate_job(jjb_template_id, *template_files)

    for key in placeholders:
        if key not in seed or seed[key] is None:
            seed[key] = defaults.get(key, None)
        env_key = "jtb_%s" % key.replace('-', '_')
        if os.getenv(env_key):
            seed[key] = os.getenv(env_key)

    print format_job(jjb_template_id, seed)



if __name__ == '__main__':

    argv = list(sys.argv)

    argv.pop(0) # scriptname

    cmd = argv.pop(0)
    if not argv:
        sys.exit(1)

    if len(argv) == 1:
        JTB_JJB_LIB = os.getenv('JTB_JJB_LIB', 'dist')
        argv.append( os.path.join( JTB_JJB_LIB, 'base.yaml' ) )

    locals()["run_"+cmd](*argv)

