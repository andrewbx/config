{ primaryUser, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      ".idea/"
      "*.iws"
      "*.iml"
      "*.ipr"
      "*.swp"
      ".DS_Store"
      "Pipfile.lock"
      "Pipfile"
      ".vscode"
      ".terraform.lock.hcl"
      ".terragrunt-cache"
      ".pre-commit-config.yaml"
    ];
    
    settings = {
      github = {
        user = primaryUser;
      };

      init = {
        defaultBranch = "master";
      };
      
      user = {
        name = "Andrew";
        mail = "andrew@devnull.uk";
      };

      commit = {
        verbose = true;
        requireForce = true;
      };

      core = {
        editor = "vim";
        excludesfile = "~/.gitignore";
      };    
    };
  };
}
