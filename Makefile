default:
	@echo "To update remote jobs, run 'update'. This includes 'test'. "
	@echo "After changing tpl, recompile with 'make dist'. "

test:
	./test_relpath.sh
	jenkins-jobs test dist/base.yaml:jtb.yaml

update: DRY := 1
update:
	DRY=$(DRY) ./update.sh

dist::
	./jtb-process.sh tpl dist

