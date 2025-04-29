{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.snell-server;
  configFile = pkgs.writeText "snell.conf" ''
    [snell-server]
    listen = ${
      if cfg.ipv6
      then "::0"
      else "0.0.0.0"
    }:${toString cfg.port}
    psk = ${cfg.psk}
    ipv6 = ${boolToString cfg.ipv6}
    ${optionalString (cfg.obfs != "off") ''
      obfs = ${cfg.obfs}
      obfs-host = ${cfg.obfsHost}
    ''}
  '';
in {
  options.services.snell-server = {
    enable = mkEnableOption "Snell proxy server";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../../pkgs/by-name/sn/snell-server/package.nix {};
      defaultText = literalExpression "pkgs.snell-server";
      description = "Snell is a lean encrypted proxy protocol";
    };

    ipv6 = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable IPv6 support";
    };

    port = mkOption {
      type = types.port;
      default = 54321;
      description = "Port number to listen on (1-65535)";
    };

    psk = mkOption {
      type = types.str;
      description = "Pre-shared key for authentication";
    };

    obfs = mkOption {
      type = types.enum ["off" "http" "tls"];
      default = "off";
      description = "Obfuscation method (off/http/tls)";
    };

    obfsHost = mkOption {
      type = types.str;
      default = "bing.com";
      description = "Obfuscation hostname (used when obfs is enabled)";
    };
  };

  config = mkIf cfg.enable {
    environment.etc."snell/config.conf".source = configFile;

    systemd.services.snell-server = {
      description = "Snell Proxy Server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/snell-server -c /etc/snell/config.conf";
        Restart = "on-failure";
        DynamicUser = true;
        StateDirectory = "snell";
        ${optionalString (cfg.port < 1024) "AmbientCapabilities = CAP_NET_BIND_SERVICE;"}
        ${optionalString (cfg.port < 1024) "CapabilityBoundingSet = CAP_NET_BIND_SERVICE;"}
      };
    };
  };
}
