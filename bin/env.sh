
test -n "$JTB_HOME" || export JTB_HOME=$(dirname $(dirname $0))
test -n "$JTB_SH_BIN" || export JTB_SH_BIN=$JTB_HOME/bin
test -n "$JTB_SH_LIB" || export JTB_SH_LIB=$JTB_HOME/lib
# share dist with JJB YAML files
test -n "$JTB_JJB_LIB" || export JTB_JJB_LIB=$JTB_HOME/dist
# TODO: use jtb-lib-name iso. base.yaml. Ext also? Both not needed right now.
test -n "$JTB_LIB_NAME" || export JTB_LIB_NAME=base.yaml
# share tools, script, tpl?
test -n "$JTB_SHARE" || export JTB_SHARE=$JTB_HOME

test -n "$verbosity" || verbosity=4

# Id: jtb/0.0.4-dev bin/env.sh
