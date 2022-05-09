FROM archlinux:latest

# allow use of cache server
ARG PACMAN_CACHE_SERVER
RUN [ -z "${PACMAN_CACHE_SERVER}" ] || echo "Server = ${PACMAN_CACHE_SERVER}" > /etc/pacman.d/mirrorlist

RUN pacman -Sy --noconfirm texlive-most && pacman -Scc --noconfirm
# RUN pacman -Sy --noconfirm pandoc && pacman -Scc --noconfirm
# use upstream static binary as to not pull in a whackton of haskell deps
ARG PANDOC_VER=2.18
RUN curl -L https://github.com/jgm/pandoc/releases/download/${PANDOC_VER}/pandoc-${PANDOC_VER}-linux-amd64.tar.gz | \
    tar xz --strip-components 1 -C /usr/local

# add some helpful pandoc filters
RUN pacman -Sy --noconfirm python python-pip && pip install pantable pandoc-include pandoc-run-filter

# add some csls
WORKDIR /root/.pandoc/csl
RUN pacman -Sy --noconfirm wget && \
	wget -O apa.csl https://github.com/citation-style-language/styles/raw/master/apa.csl && \
	wget -O ieee.csl https://github.com/citation-style-language/styles/raw/master/ieee.csl && \
	wget -O mla.csl https://github.com/citation-style-language/styles/raw/master/modern-language-association.csl && \
	pacman -Rns --noconfirm wget && pacman -Scc --noconfirm

WORKDIR /data
ENTRYPOINT ["pandoc"]
