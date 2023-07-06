FROM docker.io/zocker160/aur-builder as builder

# install pandoc and filters from aur since installing packages system-wide via
# pip is blocked now (good)
USER builder
RUN yay -Sy --noconfirm --noeditmenu --nodiffmenu \
			pandoc-bin python-pantable python-pandoc-include && \
		mkdir /build/packages && \
		find /build/.cache/yay/ -name '*.pkg.tar.zst' | xargs -I _ mv _ /build/packages/

FROM docker.io/archlinux:latest

# add some csls
RUN mkdir -p /root/.pandoc/csl/ && \
		curl -sS https://github.com/citation-style-language/styles/raw/master/apa.csl -o /root/.pandoc/csl/apa.csl && \
		curl -sS https://github.com/citation-style-language/styles/raw/master/ieee.csl -o /root/.pandoc/csl/ieee.csl && \
		curl -sS https://github.com/citation-style-language/styles/raw/master/modern-language-association.csl -o /root/.pandoc/csl/mla.csl

ARG PDF_ENGINE=tectonic
ARG PDF_ENGINE_PACKAGE=${PDF_ENGINE}
RUN pacman -Sy --noconfirm --cachedir=/tmp ${PDF_ENGINE_PACKAGE} && \
		rm -rf /tmp*

COPY --from=builder /build/packages /tmp/packages
RUN pacman -U --noconfirm --cachedir=/tmp /tmp/packages/* && \
		rm -rf /tmp*

WORKDIR /data
ENV PDF_ENGINE=${PDF_ENGINE}
ENTRYPOINT pandoc --pdf-engine=\$PDF_ENGINE \$@
