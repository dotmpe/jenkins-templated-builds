#!/usr/bin/env python
"""

Helper to find template from files, return placeholders,
and generate new job definition using template.

Commands:

    vars <template-id> <yaml-file>..

    generate <template-id> <yaml-file>..

    preset <preset-id>

"""
import os
import re
import sys

import yaml


version = '0.0.2-test' # jtb

def get_template(path, jjb_template_id):

    base = yaml.load(open(path))

    for item in base:
        if 'job-template' in item:
            if item['job-template']['name'] == jjb_template_id:
                return item['job-template']


def get_preset(path):

    base = yaml.load(open(path))
    assert len(base[0].keys()) == 1
    return base[0].items()[0]


ignored_keys = "name parameters triggers scm builders publishers wrappers axes".split(' ')

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


re_var = re.compile('\{[A-Za-z0-9_\.\:-]+\}')

def find_template_vars_str(st):

    m = re_var.findall(st)
    if isinstance(m, list) and m:
        for i in m:
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

def format_job(jjb_template_id, seed):

    """
    Given template ID and placeholder values, generate a YAML file
    that defines a Jenkins job by specifying a JJB 'project' object with one
    templated jobs.
    """

    obj = '\n    '.join([
        "%s: %s" % (k, repr(v)) for k,v in seed.items()
    ])
    name = seed['name']
    del seed['name']
    return """
- project:
    name: '$s'

    jobs:
    - '%s':
        %s

""" % ( name, obj, jjb_template_id )


def find_template(jjb_template_id, *template_files):
    for path in template_files:
        template = get_template(path, jjb_template_id)
        if not template:
            raise Exception("No template with name %s" % jjb_template_id)

    print '# Found', jjb_template_id, 'in', path
    return path, template


def run_generate(jjb_template_id, *template_files):

    path, template = find_template(jjb_template_id, *template_files)
    placeholders = list(find_template_vars(template))
    defaults = get_defaults(path, placeholders, jjb_template_id)
    seed = dict( zip(placeholders, ( [None] * len(placeholders) )) )

    assert len(seed.keys()) == len(placeholders), \
            "Expected unique JJB template variables"

    for key in placeholders:
        seed[key] = os.getenv(key, defaults.get(key, None))

    assert seed['name'], "At least {name} is required"

    print format_job(jjb_template_id, seed)


def run_vars(jjb_template_id, *template_files):

    path, template = find_template(jjb_template_id, *template_files)
    placeholders = list(find_template_vars(template))
    defaults = get_defaults(path, placeholders, jjb_template_id)
    seed = dict( zip(placeholders, ( [None] * len(placeholders) )) )

    assert len(seed.keys()) == len(placeholders), \
            "Expected unique JJB template variables"

    for key in placeholders:
        seed[key] = os.getenv(key, defaults.get(key, None))

    for key in placeholders:
        print key, seed.get(key, None)


def run_preset(preset_file, *template_files):

    jjb_template_id, seed = get_preset(preset_file)

    path, template = find_template(jjb_template_id, *template_files)
    placeholders = list(find_template_vars(template))
    defaults = get_defaults(path, placeholders, jjb_template_id)
    for key in placeholders:
        if key not in seed or seed[key] == None:
            seed[key] = defaults.get(key, None)

    print format_job(jjb_template_id, seed)



if __name__ == '__main__':

    argv = list(sys.argv)

    scriptname = argv.pop(0)
    if not argv:
        exit(1)

    cmd = argv.pop(0)

    if not argv:
        exit(1)

    jjb_template_id = argv.pop(0)
    if argv:
        paths = argv
    else:
        paths = ['tpl/base.yaml']
    args = [jjb_template_id] + paths

    locals()["run_"+cmd](*args)

