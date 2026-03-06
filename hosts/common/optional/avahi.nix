{
  # Avahi - Zero-configuration networking (mDNS/DNS-SD)
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable NSS-mDNS for .local domain resolution
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Open firewall for mDNS
  networking.firewall.allowedUDPPorts = [5353];
}
