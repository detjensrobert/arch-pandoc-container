FROM archlinux:latest

# allow use of cache server
ARG PACMAN_CACHE_SERVER
RUN [ -z "${PACMAN_CACHE_SERVER}" ] || echo "Server = ${PACMAN_CACHE_SERVER}" > /etc/pacman.d/mirrorlist

RUN cat /etc/pacman.d/mirrorlist

RUN pacman -Sy --noconfirm texlive-most && pacman -Scc --noconfirm
# RUN pacman -Sy --noconfirm pandoc && pacman -Scc --noconfirm
# use upstream static binary as to not pull in a whackton of haskell deps
ARG PANDOC_VER=2.18
RUN curl -L https://github.com/jgm/pandoc/releases/download/${PANDOC_VER}/pandoc-${PANDOC_VER}-linux-amd64.tar.gz | \
    tar xz --strip-components 1 -C /usr/local

# add some helpful pandoc filters
RUN pacman -Sy --noconfirm python python-pip && pip install pantable pandoc-include pandoc-run-filter

WORKDIR /data
ENTRYPOINT ["pandoc"]
