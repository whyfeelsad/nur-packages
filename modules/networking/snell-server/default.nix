{ config, lib, ... }:

with lib;

let
  cfg = config.services.snell-server;
in
{
  options.services.snell-server = {
    enable = mkEnableOption (lib.mdDoc "Snell Server");

    port = mkOption {
      type = types.int;
      default = 2345;
      description = lib.mdDoc "The port Snell Server listens on.";
    };

    ipv6 = mkOption {
      type = types.bool;
      default = true;
      description = lib.mdDoc "Enable or disable IPv6 support.";
    };

    psk = mkOption {
      type = types.str;
      description = lib.mdDoc "The pre-shared key for authentication. This is a required option.";
    };

    obfs = mkOption {
      type = types.enum [
        "off"
        "tls"
        "http"
      ];
      default = "off";
      description = lib.mdDoc "The obfuscation method to use.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.snell-server ];

    systemd.services.snell-server = {
      description = "Snell Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.snell-server}/bin/snell-server -c ${cfg.configPath}";
        Restart = "always";
        RestartSec = "10s";
      };

      cfg.configPath = pkgs.writeText "snell-server.conf" ''
        [snell-server]
        listen = ${if cfg.ipv6 then "::0:" else "0.0.0.0:"}${toString cfg.port}
        ipv6 = ${if cfg.ipv6 then "true" else "false"}
        psk = ${cfg.psk}
        obfs = ${cfg.obfs}
      '';
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}
