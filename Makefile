default:
	@echo "To update remote jobs, run 'update'. This includes 'test'. "
	@echo "After changing tpl, recompile with 'make dist'. "

test:: BRANCH := test
test::
	test -z "$(which git-versioning)" || git-versioning check
	test -z "$$JTB_HOME" -o "$$(cd $$JTB_HOME; pwd -P)" = "$$(pwd -P)" || { \
		cd "$$JTB_HOME" \
			&& echo "Host: $$(hostname) User: $$(whoami) PWD: $$(pwd)" \
			&& git remote -v \
			&& git checkout $(BRANCH) && git pull origin "$(BRANCH)"; \
	}
	@failed=/tmp/jtb-test.failed; \
	for preset_path in preset/*.yaml; do \
		preset=$$(basename $$preset_path .yaml); \
		./bin/jtb.sh compile-preset $$preset || { \
			echo jtb:compile-preset:$$preset >>$$failed; \
			continue; } \
		DRY=1 files=$$preset.yaml:dist/base.yaml ./bin/jtb.sh update || {
			echo jtb:update:dry-run:preset:$$preset >>$$failed; \
		}; \
	done; \
	@for jjb_path in example/*.yaml ./*.yaml; do \
		DRY=1 files=$$jjb_path:dist/base.yaml ./bin/jtb.sh update \
		|| echo jtb:update:dry-run:$$jjb_path >>$$failed; \
	done; \
	$(shell hostname -s | tr 'a-z' 'A-Z' | sed 's/[^0-9A-Z_]/_/g')_SKIP=1 \
		./test/*-spec.bats || echo jtb:bats >>$$failed; \
	test -s "$$failed" && { echo "Failed tests:";cat $$failed;\
			} || rm -f $$failed

	#jenkins-jobs test dist/base.yaml:jtb.yaml

update: DRY := 1
update: FILES := 
update:
	DRY=$(DRY) files="$(FILES)" ./bin/jtb.sh update

# Compile source to packaged template sets.
dist::
	test -z "$(which git-versioning)" || git-versioning check
	mkdir -vp $@
	./bin/jtb.sh process tpl $@

build::
	./bin/jtb.sh build

clean::
	rm -rf dist build

