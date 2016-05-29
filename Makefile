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
	@for preset_path in preset/*.yaml; do \
		preset=$$(basename $$preset_path .yaml); \
		./bin/jtb.sh compile-preset $$preset || exit $?; \
		DRY=1 files=$$preset.yaml:dist/base.yaml ./bin/jtb.sh update || exit $?; \
	done
	@for jjb_path in example/*.yaml ./*.yaml; do \
		DRY=1 files=$$jjb_path:dist/base.yaml ./bin/jtb.sh update || exit $?; \
	done
	$(shell hostname -s | tr 'a-z' 'A-Z' | sed 's/[^0-9A-Z_]/_/g')_SKIP=1 \
		./test/*-spec.bats
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

