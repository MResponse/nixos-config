{ config, lib, pkgs, ... }: {
  services = {
    pcscd.enable = true;
    logind.lidSwitchExternalPower = "ignore";
    pipewire.wireplumber.enable = true;
    emacs.enable = true;
    printing.enable = true;
    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
