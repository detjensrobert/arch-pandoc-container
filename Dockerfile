FROM docker.io/archlinux:latest

RUN pacman -Sy --noconfirm tectonic && pacman -Scc --noconfirm

# RUN pacman -Sy --noconfirm pandoc && pacman -Scc --noconfirm
# use upstream static binary as to not pull in a whackton of haskell deps
ARG PANDOC_VERSION=2.19.2
RUN curl -L https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz | \
    tar xz --strip-components 1 -C /usr/local

# add some helpful pandoc filters
RUN pacman -Sy --noconfirm python python-pip && pacman -Scc --noconfirm && pip install pantable pandoc-include

# add some csls
RUN mkdir -p /root/.pandoc/csl/ && \
		curl -sS https://github.com/citation-style-language/styles/raw/master/apa.csl -o /root/.pandoc/csl/apa.csl && \
		curl -sS https://github.com/citation-style-language/styles/raw/master/ieee.csl -o /root/.pandoc/csl/ieee.csl && \
		curl -sS https://github.com/citation-style-language/styles/raw/master/modern-language-association.csl -o /root/.pandoc/csl/mla.csl

WORKDIR /data
ENTRYPOINT ["pandoc", "--pdf-engine=tectonic"]
