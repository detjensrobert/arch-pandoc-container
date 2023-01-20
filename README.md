# arch-pandoc-container

Ubuntu's version of [Pandoc](https://pandoc.org) is old and doesn't like some raw LaTeX macros I use for some classes,
and the official [`pandoc/latex`](https://hub.docker.com/repository/docker/pandoc/latex) image does not have all of the
needed LaTeX packages for those macros either. This Docker container provides Arch's versions of Pandoc and TeXLive,
which work just fine.

Additionally, this bundles MLA, APA, and IEEE [CSLs](https://github.com/citation-style-language/styles) for citations, along with some Pandoc
filters:

- [`pantable`](https://github.com/ickc/pantable)
- [`pandoc-include`](https://github.com/DCsunset/pandoc-include)

## Tags

Images are tagged based on the Pandoc version and the LaTeX engine included.

The `:latest` tag ships with [Tectonic](https://tectonic-typesetting.github.io) as the LaTeX engine for a much smaller container size, but may not work for all LaTeX packages.

- `:latest`
- `:<version>` (e.g. `:3.0`)
- `:<version>-tectonic` (e.g. `:3.0-tectonic`)

The `:full` tag has the more 'standard' [TeXLive](https://www.tug.org/texlive) installation, but is a much larger container (over 2GB!).

- `:full`
- `:<version>-texlive` (e.g. `:3.0-texlive`)

Images are available both on [Dockerhub](https://hub.docker.com/r/detjensrobert/arch-pandoc) and on [GHCR](https://github.com/detjensrobert/arch-pandoc-container/pkgs/container/arch-pandoc):

```sh
docker pull docker.io/detjensrobert/arch-pandoc
docker pull ghcr.io/detjensrobert/arch-pandoc
```

## Usage:

Use this as a drop-in for standard `pandoc`:

```bash
docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) detjensrobert/arch-pandoc -s file.md -o file.pdf ...
```

- This container expects all necessary files to be mounted at `/data` in the container: `-v $(pwd):/data`

- To avoid output being owned by `root`, run the entrypoint as your UID/GID: `-u $(id -u):$(id -g)`
  > NOTE: if using rootless containers, e.g. `podman`, this is not needed! `root` in the container is already mapped to your normal user.

  > NOTE 2: If this causes permission errors with a Tectonic image, try switching to the TeXLive image instead.

Add this shell function to your shell config for convenience:

```bash
pandoc-docker () {
  docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) detjensrobert/arch-pandoc $@
}

md2pdf-docker () {
  pandoc-docker -s "$1" -o "${1%%.md}.pdf" -V geometry:margin=1in --highlight=tango --citeproc ${@:2}
}

# usage:
md2pdf-docker some-document.md --filter pantable  # -> creates some-document.pdf
```
