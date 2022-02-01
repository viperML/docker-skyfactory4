Docker image builder for SkyFactory 4.

Based on [github.com/mikenoethiger/skyfactory4](https://github.com/mikenoethiger/skyfactory4/blob/master/Dockerfile), but I wanted to cross compile aarch64 images.

## Usage

- Input this flake into the flake for your NixOS configuration
- Use the option `virtualisation.oci-containers.containers.<name>.imageFile` to reference the flake output `<this-flake>.packages.<system>.docker-image`
