build:
  docker build -t dev-env .

run: build
  docker run --rm -it \
    -v ~/projects/:/workspace/projects \
    dev-env
