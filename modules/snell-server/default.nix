{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.snell-server;
  pkg = pkgs.callPackage ../../pkgs/by-name/snell-server;
in {
  options.services.snell-server = {
    enable = mkEnableOption "Snell Server";

    package = mkOption {
      type = types.package;
      default = pkg;
      defaultText = literalExpression "pkgs.snell-server";
      description = "The snell-server package to use.";
    };

    port = mkOption {
      type = types.port;
      description = "The port that snell server will listen on.";
    };

    ipv6 = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable IPv6 support.";
    };

    psk = mkOption {
      type = types.str;
      description = "The pre-shared key for authentication.";
    };

    obfs = mkOption {
      type = types.str;
      default = "off";
      description = "The obfuscation method to use (off, http, tls).";
    };

    obfsHost = mkOption {
      type = types.str;
      default = "icloud.com";
      description = "The hostname for obfuscation.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.snell-server = {
      description = "Snell Server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/snell-server -c /etc/snell-server.conf";
        Restart = "always";
        RestartSec = "3";
        User = "snell";
        Group = "snell";
        AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
      };
    };

    users.users.snell = {
      isSystemUser = true;
      group = "snell";
      description = "Snell Server service user";
    };

    users.groups.snell = {};

    environment.etc."snell-server.conf".text = ''
      [snell-server]
      listen = ${
        if cfg.ipv6
        then "::0"
        else "0.0.0.0"
      }:${toString cfg.port}
      psk = ${cfg.psk}
      ipv6 = ${
        if cfg.ipv6
        then "true"
        else "false"
      }
      obfs = ${cfg.obfs}
      obfs-host = ${cfg.obfsHost}
    '';
  };
}
