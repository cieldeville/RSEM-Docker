# RSEM-Docker
[![Docker Image Version](https://img.shields.io/docker/v/cieldeville/rsem?label=Image%20Version)](https://hub.docker.com/r/cieldeville/rsem) [![Docker Image Size](https://img.shields.io/docker/image-size/cieldeville/rsem?label=Image%20Size)](https://hub.docker.com/r/cieldeville/rsem) ![License MIT](https://img.shields.io/badge/License-MIT-blue) ![Maintenance Status](https://img.shields.io/badge/Maintenance%20Status-Inactive-yellow
)

This project provides a simple Dockerfile which can be used to build docker images of various versions of the [RSEM software suite](https://github.com/deweylab/RSEM) developed by Bo Li, Colin Dewey, and Peng Liu. The image is based on Linux Debian 12.10 and includes R. Both R and RSEM get built from source.

I created this image specifically because there was an [open issue](https://github.com/deweylab/RSEM/issues/126) that would cause RSEM to complain about the mates of paired-end reads being aligned to different transcripts after being aligned through STAR. RSEM's `rsem-sam-validator`, however, would claim the files were in fact intact. A downgrade onto RSEM v1.3.0 also solved the issue. Since I could not find any existing docker images which had version 1.3.0 available (I checked [BioContainers](https://hub.docker.com/r/biocontainers/rsem) and (Nanozoo)[https://hub.docker.com/r/nanozoo/rsem]) and because package managers like Conda could also not retrieve a suitable list of dependencies for older version of RSEM anymore, I was forced to create my own image.

## Prebuilt Images

Prebuilt images for some versions of RSEM can be found on the project's [DockerHub](https://hub.docker.com/r/cieldeville/rsem). You can pull them directly from DockerHub like so:

```bash
docker pull cieldeville/rsem:<VERSION>
```

## Building Manually

You can build the Dockerfile using the supplied `build.sh` build script. The script takes three parameters which are as follows:
- RSEM version : any version that has a tag in the official [RSEM GitHub repository](https://github.com/deweylab/RSEM). Example: "1.3.3"
- R version : the desired version of R. Currently, only R versions 4.X.X are supported since the URLs for other major versions differ from the current one. Example: "4.4.3"
- How many threads to use when building RSEM and R from source

```bash
./build "1.3.3" "4.4.3" 8
```

This will build the image as `cieldeville/rsem:1.3.3`. Alternatively, you can create the image manually using the `docker build` command like this

```bash
docker build \
  --label org.opencontainers.image.created="$(date --rfc-3339=seconds)" \
  --build-arg RSEM_VERSION=1.3.3 \
  --build-arg R_VERSION=4.4.3 \
  --build-arg MAKE_NTHREADS=8 \
  --tag cieldeville/rsem:1.3.3 \
  -f Dockerfile .
```

## License

The code in this repository is licensed under the MIT license.

For the license of the RSEM software suite, please consult the [RSEM GitHub repository](https://github.com/deweylab/RSEM).  
For the license of R please consult the [R project's homepage](https://www.r-project.org/Licenses/).  
For any licenses applicable to Debian 12.10 and its pre-installed components, please consult the respective manuals for details.


## Contact

If you have any questions, feel free to contact me at < ciel.dev \[you know which sign\] pm.me >.
