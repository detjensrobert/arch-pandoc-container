FROM docker.io/archlinux:latest

# add some csls
RUN mkdir -p /root/.pandoc/csl/ && \
		curl -sS https://github.com/citation-style-language/styles/raw/master/apa.csl -o /root/.pandoc/csl/apa.csl && \
		curl -sS https://github.com/citation-style-language/styles/raw/master/ieee.csl -o /root/.pandoc/csl/ieee.csl && \
		curl -sS https://github.com/citation-style-language/styles/raw/master/modern-language-association.csl -o /root/.pandoc/csl/mla.csl

ARG PDF_ENGINE=tectonic
ARG PDF_ENGINE_PACKAGE=${PDF_ENGINE}
RUN pacman --noconfirm --cachedir=/tmp -q -Sy ${PDF_ENGINE_PACKAGE} && \
		# also add some helpful pandoc filters
		pacman --noconfirm --cachedir=/tmp -q -Sy python python-pip && \
		pip --cache-dir=/tmp install pantable pandoc-include && \
		rm -rf /tmp*

# use upstream static binary as to not pull in a whackton of haskell deps
ARG PANDOC_VERSION=3.1.2
RUN curl -sSL https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz | \
    tar xz --strip-components 1 -C /usr/local

WORKDIR /data
ENV PDF_ENGINE=${PDF_ENGINE}
ENTRYPOINT pandoc --pdf-engine=\$PDF_ENGINE \$@
