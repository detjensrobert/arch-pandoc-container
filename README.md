# arch-pandoc-container

Ubuntu's version of [Pandoc](https://pandoc.org) is old and doesn't like some raw LaTeX macros I use for some classes,
and the official [`pandoc/latex`](https://hub.docker.com/repository/docker/pandoc/latex) image does not have all of the
needed LaTeX packages for those macros either.

This Docker container provides Arch's versions of Pandoc and TeXLive, which work just fine, along with some Pandoc
filters I use sometimes: [`pantable`](https://github.com/ickc/pantable),
[`pandoc-include`](https://github.com/DCsunset/pandoc-include), and
[`pandoc-run-filter`](https://github.com/johnlwhiteman/pandoc-run-filter).

## Usage:

- This container expects all necessary files to be mounted at `/data` in the container.
  - `-v $(pwd):/data`
- To avoid output being owned by `root`, run the entrypoint as your UID/GID.
  - `-u $(id -u):$(id -g)`
  - *NOTE: if using rootless containers, e.g. `podman`, don't include this!*

    `root` in the container is already mapped to your normal user.

Use this as a drop-in for standard `pandoc`:

```bash
docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) detjensrobert/arch-pandoc -s file.md -o file.pdf ...
```

Add this shell function / alias to your shell's rc for convenience:

```bash
pandoc-docker () {
  docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) detjensrobert/arch-pandoc $@
}

md2pdf-docker () {
  pandoc-docker -s "$1" -o "${1%%.md}.pdf" -V geometry:margin=1in --highlight=tango --citeproc ${@:2}
}
```
