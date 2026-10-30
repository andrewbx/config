{ config, ... }:

let
  work = config.myConfig.work;
in
{
  services.forgejo = {
    enable = true;
    stateDir = "${work}/Forgejo";
    database = {
      type = "sqlite3";
    };

    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = "devnull.uk";

        HTTP_ADDR = "0.0.0.0";
        HTTP_PORT = 3001;
        SSH_PORT = 2222;

        SSH_DOMAIN = "gitssh.devnull.uk";
        ROOT_URL = "https://github.devnull.uk/";

        START_SSH_SERVER = true;
        BUILTIN_SSH_SERVER_USER = "git";

        LANDING_PAGE = "login";
      };

      service = {
        DISABLE_REGISTRATION = true;
      };

      repository = {
        DEFAULT_PRIVATE = "private";
      };

      security = {
        INSTALL_LOCK = true;
      };

      actions = {
        ENABLED = true;
      };

      ui = {
        SKIP_ESCAPE_CONTEXTS = "file-view,diff";
      };
    };
  };

  environment.systemPackages = [
    config.services.forgejo.package
  ];

  networking.firewall.allowedTCPPorts = [
    3001
    2222
  ];
}
