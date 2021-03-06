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
            docker-image = pkgs.dockerTools.buildLayeredImage {
              name = "viperml/skyfactory-4";
              tag = "latest";
              contents = [
                pkgs.bash
                pkgs.coreutils
                pkgs.jdk8
              ];
              extraCommands = ''
                mkdir -p ./${workdir}
                cp -r ${server-files}/* ./${workdir}
                ${pkgs.gnused}/bin/sed 's/\. \.\/settings\.sh//g' ./${workdir}/ServerStart.sh
              '';
              config = {
                Cmd = [ "${entrypoint}/bin/entrypoint" ];
                WorkingDir = workdir;
                Env = [
                  "PATH=${pkgs.jdk8}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin"
                  "MIN_RAM=1024M"
                  "MAX_RAM=4096M"
                  "JAVA_PARAMETERS=-XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -Dfml.readTimeout=180"
                ];
              };
            };
          };

        });

    };
}
