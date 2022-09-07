FROM archlinux:latest

# allow use of cache server
ARG PACMAN_CACHE_SERVER
RUN [ -z "${PACMAN_CACHE_SERVER}" ] || echo "Server = ${PACMAN_CACHE_SERVER}" > /etc/pacman.d/mirrorlist

RUN pacman -Sy --noconfirm tectonic && pacman -Scc --noconfirm

# RUN pacman -Sy --noconfirm pandoc && pacman -Scc --noconfirm
# use upstream static binary as to not pull in a whackton of haskell deps
ARG PANDOC_VER=2.19
RUN curl -L https://github.com/jgm/pandoc/releases/download/${PANDOC_VER}/pandoc-${PANDOC_VER}-linux-amd64.tar.gz | \
    tar xz --strip-components 1 -C /usr/local

# add some helpful pandoc filters
RUN pacman -Sy --noconfirm python python-pip && pip install pantable pandoc-include pandoc-run-filter

# add some csls
ADD https://github.com/citation-style-language/styles/raw/master/apa.csl \
		https://github.com/citation-style-language/styles/raw/master/ieee.csl \
		https://github.com/citation-style-language/styles/raw/master/modern-language-association.csl \
		/root/.pandoc/csl/

WORKDIR /data
ENTRYPOINT ["pandoc", "--pdf-engine=tectonic"]
