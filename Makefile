default:
	@echo "To update remote jobs, run 'update'. This includes 'test'. "

test:
	./test_relpath.sh
	jenkins-jobs test dist/base.yaml:jtb.yaml

update: DRY := 1
update:
	DRY=$(DRY) ./update.sh
