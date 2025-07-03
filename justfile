
default: run

run:
  love src

watch:
    fd -e lua | entr -r just run
