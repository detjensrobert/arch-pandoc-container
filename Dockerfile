FROM docker.io/zocker160/aur-builder as builder

# install filters from aur since installing pip packages as root is blocked
# (this is good but annoying here)
USER builder
RUN yay -Sy --noconfirm --noeditmenu --nodiffmenu \
      python-pantable python-pandoc-include && \
    mkdir /build/packages && \
    find /build/.cache/yay/ -name '*.pkg.tar.zst' | xargs -I _ mv _ /build/packages/

# also create dummy pandoc package so filter deps are happy in final container
RUN echo -e "pkgname=pandoc-dummy\npkgver=9.99\npkgrel=1\narch=('any')\nprovides=(pandoc pandoc-cli)" > PKGBUILD.pandoc-dummy && \
    PKGDEST=/build/packages/ makepkg -p PKGBUILD.pandoc-dummy

FROM docker.io/archlinux

# add some csls
RUN mkdir -p /root/.pandoc/csl/ && \
    curl -sS https://github.com/citation-style-language/styles/raw/master/apa.csl -o /root/.pandoc/csl/apa.csl && \
    curl -sS https://github.com/citation-style-language/styles/raw/master/ieee.csl -o /root/.pandoc/csl/ieee.csl && \
    curl -sS https://github.com/citation-style-language/styles/raw/master/modern-language-association.csl -o /root/.pandoc/csl/mla.csl

RUN pacman -Sy --noconfirm --cachedir=/tmp tectonic && \
    rm -rf /tmp/*

COPY --from=builder /build/packages /tmp/packages
RUN pacman -U --noconfirm --cachedir=/tmp /tmp/packages/* && \
    rm -rf /tmp/*

# use upstream static binary to control version
# and not pull in a whackton of haskell deps in final container
ARG PANDOC_VERSION=3.1.8
RUN curl -sSL https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz | \
    tar xz --strip-components 1 -C /usr/local

# prime tectonic tex package cache with common packages
# COPY --from=docker.io/rekka/tectonic /root/.cache/Tectonic/ /root/.cache/Tectonic
RUN echo -e "# Test document!\n\nJust some markdown here." | \
    pandoc --pdf-engine=tectonic -s - -f markdown -o /dev/null -t pdf

WORKDIR /data
ENTRYPOINT ["pandoc", "--pdf-engine=tectonic"]
