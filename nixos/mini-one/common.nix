{ lib, ... }:

{
  options.myConfig = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "andrew";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
    };

    work = lib.mkOption {
      type = lib.types.str;
      default = "/work";
    };
  };
}
