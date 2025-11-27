{ ... }:
{
  environment = {
    sessionVariables = {
      # Program variables
      GIT_EDITOR = "nvim";
    };

    # Add ./local/bin to PATH
    localBinInPath = true;
  };
}
