{lib, ...}: {
  virtualisation.oci-containers.containers."echo-http-service" = {
    image = "hashicorp/http-echo";
    extraOptions = ["-text='Hello, World!'" "--network=web"];
    ports = ["5678:5678"];
  };
  system.activationScripts.createPodmanNetworkWeb = lib.mkAfter ''
    if ! /run/current-system/sw/bin/podman network exists web; then
      /run/current-system/sw/bin/podman network create web
    fi
  '';
}
