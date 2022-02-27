# arch-pandoc-container

Ubuntu's version of [Pandoc](https://pandoc.org) is old and doesn't like some raw LaTeX macros I use for some classes.

This Docker container provides Arch's Pandoc + TeXLive, which works fine.

## Usage:

Use this as a drop-in for standard `pandoc`:

```bash
docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) detjensrobert/arch-pandoc file.md -o file.pdf
```

Or as an alias:

```bash
pandoc-docker () {
  docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) detjensrobert/arch-pandoc
}

```
