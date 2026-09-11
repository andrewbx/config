{ config, pkgs, lib, ... }:
{
  # Technitium DNS.
  services.technitium-dns-server = {
    enable = true;
    package = pkgs.runCommand "technitium-dns-server-15.4" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/lib/technitium-dns-server $out/bin

      ${pkgs.gnutar}/bin/tar -xzvf ${pkgs.fetchurl {
        url = "https://download.technitium.com/dns/DnsServerPortable.tar.gz";
        hash = "sha256-RhrAnUMErOhQk/wXsQp+4TqHlurgrbQ5OGa9TWarKD8=";
      }} -C $out/lib/technitium-dns-server

    makeWrapper ${pkgs.dotnetCorePackages.aspnetcore_10_0}/bin/dotnet $out/bin/technitium-dns-server \
      --add-flags "$out/lib/technitium-dns-server/DnsServerApp.dll" \
      --set DOTNET_ROOT "${pkgs.dotnetCorePackages.aspnetcore_10_0}/share/dotnet"
    '';
  };

  # Technitium DNS User.
  users.groups.technitium = {};
  users.users.technitium = {
    isSystemUser = true;
    group = "technitium";
    home = "/var/lib/technitium-dns-server";
    createHome = true;
  };

  # Technitium System/.NET tweaks.
  systemd.services.technitium-dns-server = {
    environment = {
      DOTNET_gcServer = "0";
      COMPlus_gcServer = "0";
      DOTNET_gcConcurrent = "1";
      COMPlus_gcConcurrent = "1";
      DOTNET_GCHighMemPercent = "40";
      COMPlus_GCHighMemPercent = "40";
      DOTNET_GCHeapHardLimit = "1610612736"; 
      COMPlus_GCHeapHardLimit = "1610612736";
      DOTNET_THREADPOOL_MINTHREADS = "2";
      DOTNET_THREADPOOL_MAXTHREADS = "6"; 
      COMPlus_THREADPOOL_MINTHREADS = "2";
      COMPlus_THREADPOOL_MAXTHREADS = "6";
    };
    serviceConfig = {
      User = "technitium";
      Group = "technitium";
      StateDirectory = "technitium-dns-server";
      DynamicUser = lib.mkForce false;
      TimeoutStartSec = 30;

      # FIX: Isolate the filesystem so .NET cannot crawl /nix/store
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadOnlyPaths = [ "/nix/store" ];
      ReadWritePaths = [ "/var/lib/technitium-dns-server" ];
      WorkingDirectory = lib.mkForce "/var/lib/technitium-dns-server";
    
      # Ensure systemd allows binding low ports if running as standard user
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
    wantedBy = [ "multi-user.target" ];
  };

  fileSystems."/var/lib/technitium-dns-server/logs" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=64M" ];
  };

  services.rsyslogd.extraConfig = ''
    input(
      type="imfile"
      File="/var/lib/technitium-dns/logs/*.log"
      Tag="technitium-dns"
      StateFile="imfile-technitium-dns"
      Severity="info"
      Facility="local0"
      PersistStateInterval="200"
      readMode="1"
    )
  '';
}
