CRYSTAL_BIN = $(shell which crystal)
SHARDS_BIN = $(shell which shards)
PREFIX = $(HOME)
EXEC = "mymodern"

build:
	$(SHARDS_BIN) build
build_release:
	$(SHARDS_BIN) build --release

# The 'list' target displays all the available targets and their descriptions in
# the current Makefile. It uses the $(firstword $(MAKEFILE_LIST)) expression to
# get the name of the current Makefile, and then searches for lines starting with
# a word character followed by a colon (target names).
# The grep -v '^#' filters out any lines starting with '#' (comments) that are
# commented out tasks. The -A 1 option lists the line that comes after the matched
# target as well, either the command or a descriptive comment for the task.

list:
	@grep -A 1 "^\w\+:" $(firstword $(MAKEFILE_LIST)) | grep -v '^#'
format:
	$(CRYSTAL_BIN) tool format -e lib
test:
	$(CRYSTAL_BIN) spec
diff_mock:
	# compare bin/$(EXEC) --mock with fixture
	@ bin/$(EXEC) -m > tmp_result
	@if cmp -s tmp_result spec/fixtures/mock_expected; then \
	  echo "files are the same"; \
	else \
	  echo "*******************"; \
	  echo "files are different"; \
	  echo "*******************"; \
	fi
	@rm tmp_result
