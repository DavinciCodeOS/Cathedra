# Cathedra

This repository contains all container configuration we deploy for the building process.

## How to use?

1. We assume that you have a properly set up basic `docker`/`podman` installation
2. clone the repository
3. populate the `keys/` folder with an SSH key and propagate it to sourceforge or set `UPLOAD_TO_SF` to `false` (check `build.sh` for the details)
4. run `docker build -t pebuild:latest .`
5. run `docker create --name=pebuild pebuild:latest`
6. start the container `docker start pebuild`
7. you may follow the build process by executing `docker logs -f pebuild`

## Legacy tree!
This branch and the build files were used to build the first releases of DavinciCodeOS based on Android 12.1 and Pixel Experience sources. Make sure to update your sources.
