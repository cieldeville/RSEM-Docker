FROM debian:12.10

ARG R_VERSION=4.4.3
ARG RSEM_VERSION=1.3.0
ARG MAKE_NTHREADS=1

LABEL org.opencontainers.image.title="RSEM v${RSEM_VERSION} on Debian 12.10"
LABEL org.opencontainers.image.description="RSEM v${RSEM_VERSION} bundled with R v${R_VERSION} on Debian 12.10. Does not support integrated aligner usage to keep container image small."
LABEL org.opencontainers.image.authors="Ciel DeVille <ciel.dev@pm.me>"
LABEL org.opencontainers.image.version="${RSEM_VERSION}"

WORKDIR /usr/local/app

# Install shell tools
RUN <<EOF
apt-get update && apt-get install -y \
	git \
	wget
EOF

# Install and build R version
RUN <<EOF

sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources
apt-get update
apt-get build-dep -y r-base

wget https://cran.rstudio.com/src/base/R-4/R-${R_VERSION}.tar.gz -O - | tar -xzf -
cd R-${R_VERSION}
./configure \
  --prefix=/opt/R/${R_VERSION} \
  --enable-R-shlib \
  --enable-memory-profiling
make -j $MAKE_NTHREADS
make install

/opt/R/${R_VERSION}/bin/R --version

ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R
ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

apt-get install -y libopenblas-dev
update-alternatives --set libblas.so.3-$(arch)-linux-gnu /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3

cd ..
EOF

# Install and build RSEM version
RUN <<EOF

git clone --depth 1 --branch v${RSEM_VERSION} https://github.com/deweylab/RSEM.git RSEM-${RSEM_VERSION}
cd RSEM-${RSEM_VERSION}

apt-get install -y libncurses-dev
/opt/R/${R_VERSION}/bin/Rscript -e 'install.packages("blockmodeling", repos="http://cran.us.r-project.org")'

make -j $MAKE_NTHREADS
make ebseq
make install DESTDIR=/opt/RSEM prefix=/${RSEM_VERSION}

ln -s /opt/RSEM/${RSEM_VERSION}/bin/convert-sam-for-rsem /usr/local/bin/convert-sam-for-rsem
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-calculate-expression /usr/local/bin/rsem-calculate-expression
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-parse-alignments /usr/local/bin/rsem-parse-alignments
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-run-em /usr/local/bin/rsem-run-em
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-tbam2gbam /usr/local/bin/rsem-tbam2gbam
ln -s /opt/RSEM/${RSEM_VERSION}/bin/extract-transcript-to-gene-map-from-trinity /usr/local/bin/extract-transcript-to-gene-map-from-trinity
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-extract-reference-transcripts /usr/local/bin/rsem-extract-reference-transcripts
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-plot-model /usr/local/bin/rsem-plot-model
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-run-gibbs /usr/local/bin/rsem-run-gibbs
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem_perl_utils.pm /usr/local/bin/rsem_perl_utils.pm
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-bam2readdepth /usr/local/bin/rsem-bam2readdepth
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-gen-transcript-plots /usr/local/bin/rsem-gen-transcript-plots
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-plot-transcript-wiggles /usr/local/bin/rsem-plot-transcript-wiggles
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-sam-validator /usr/local/bin/rsem-sam-validator
ln -s /opt/RSEM/${RSEM_VERSION}/bin/samtools-1.3 /usr/local/bin/samtools-1.3
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-bam2wig /usr/local/bin/rsem-bam2wig
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-generate-data-matrix /usr/local/bin/rsem-generate-data-matrix
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-prepare-reference /usr/local/bin/rsem-prepare-reference
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-scan-for-paired-end-reads /usr/local/bin/rsem-scan-for-paired-end-reads
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-build-read-index /usr/local/bin/rsem-build-read-index
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-get-unique /usr/local/bin/rsem-get-unique
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-preref /usr/local/bin/rsem-preref
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-simulate-reads /usr/local/bin/rsem-simulate-reads
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-calculate-credibility-intervals /usr/local/bin/rsem-calculate-credibility-intervals
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-gff3-to-gtf /usr/local/bin/rsem-gff3-to-gtf
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-refseq-extract-primary-assembly /usr/local/bin/rsem-refseq-extract-primary-assembly
ln -s /opt/RSEM/${RSEM_VERSION}/bin/rsem-synthesis-reference-transcripts /usr/local/bin/rsem-synthesis-reference-transcripts

cd ..

EOF

# Clean up build files
RUN <<EOF

rm -R R-${R_VERSION}
rm -R RSEM-${RSEM_VERSION}

EOF
