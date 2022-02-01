{
  description = "Docker image for minecraft modded server SkyFactory 4";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    flake-utils-plus.url = github:gytis-ivaskevicius/flake-utils-plus;
  };

  outputs = inputs @ { self, nixpkgs, flake-utils-plus, ... }:
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      outputsBuilder = (channels:
        let
          pkgs = channels.nixpkgs;
          lib = pkgs.lib;
          version = "4.2.4";
          server-files = pkgs.fetchzip {
            url = ''https://edge.forgecdn.net/files/3565/687/SkyFactory-4_Server_${builtins.replaceStrings ["."] ["_"] version}.zip'';
            stripRoot = false;
            sha256 = "sha256-EMufZpc1uF7B7ePmztfW+S/+8OxpLeHWx6DB4VT7OSE=";
          };
          workdir = "/var/lib/skyfactory4";
          entrypoint = pkgs.writeShellScriptBin "entrypoint" ''
            set -eux -o pipefail
            cd ${workdir}
            if [[ ! -f eula.txt ]]; then
              ${pkgs.bash}/bin/bash Install.sh
              echo "eula=true" > eula.txt
            fi
            ${pkgs.bash}/bin/bash ServerStart.sh
          '';
        in
        {
          packages = {
            inherit server-files;
            docker-image = pkgs.dockerTools.buildImage {
              name = "skyfactory-4";
              tag = version + "-${pkgs.system}";
              contents = [
                pkgs.bash
                pkgs.coreutils
                pkgs.jdk8
              ];
              runAsRoot = ''
                set -eux -o pipefail
                mkdir -p ${workdir}
                cp -r ${server-files}/* ${workdir}
              '';
              config = {
                Cmd = [ "${entrypoint}/bin/entrypoint" ];
                WorkingDir = workdir;
                Env = [
                  "PATH=${pkgs.jdk8}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin"
                ];
              };
            };
          };

        });

    };
}
