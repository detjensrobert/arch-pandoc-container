FROM docker.io/zocker160/aur-builder as builder

# install filters from aur since installing pip packages as root is blocked
# (this is good but annoying here)
USER builder
RUN yay -Sy --noconfirm --noeditmenu --nodiffmenu \
      python-pantable python-pandoc-include && \
    mkdir /build/packages && \
    find /build/.cache/yay/ -name '*.pkg.tar.zst' | xargs -I _ mv _ /build/packages/

FROM docker.io/archlinux

# add some csls
RUN mkdir -p /root/.pandoc/csl/ && \
    curl -sS https://github.com/citation-style-language/styles/raw/master/apa.csl -o /root/.pandoc/csl/apa.csl && \
    curl -sS https://github.com/citation-style-language/styles/raw/master/ieee.csl -o /root/.pandoc/csl/ieee.csl && \
    curl -sS https://github.com/citation-style-language/styles/raw/master/modern-language-association.csl -o /root/.pandoc/csl/mla.csl

RUN pacman -Sy --noconfirm --cachedir=/tmp tectonic && \
    rm -rf /tmp*

COPY --from=builder /build/packages /tmp/packages
RUN pacman -U --noconfirm \
      --assume-installed pandoc-cli \
      --cachedir=/tmp /tmp/packages/* && \
    rm -rf /tmp*

# use upstream static binary to control version
# and not pull in a whackton of haskell deps in final container
ARG PANDOC_VERSION=3.1.8
RUN curl -sSL https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz | \
    tar xz --strip-components 1 -C /usr/local

WORKDIR /data
ENTRYPOINT ["pandoc", "--pdf-engine=tectonic"]
