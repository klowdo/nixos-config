{pkgs, ...}: {
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
    wireplumber = {
      enable = true;

      extraConfig = {
        # Equalizer filter chain
        "50-equalizer" = {
          "context.modules" = [
            {
              name = "libpipewire-module-filter-chain";
              args = {
                "node.description" = "Equalizer Sink";
                "media.name" = "Equalizer Sink";
                "filter.graph" = {
                  nodes = [
                    {
                      type = "builtin";
                      name = "eq_band_1";
                      label = "bq_lowshelf";
                      control = {
                        Freq = 105;
                        Q = 0.7;
                        Gain = 3.5;
                      };
                    }
                    {
                      type = "builtin";
                      name = "eq_band_2";
                      label = "bq_peaking";
                      control = {
                        Freq = 2000;
                        Q = 1.5;
                        Gain = -2.0;
                      };
                    }
                  ];
                };
                "capture.props" = {
                  "node.name" = "effect_input.eq6";
                  "media.class" = "Audio/Sink";
                };
                "playback.props" = {
                  "node.name" = "effect_output.eq6";
                  "node.passive" = true;
                };
              };
            }
          ];
        };

        # Bluetooth configuration
        "10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true; # Higher quality SBC codec
            "bluez5.enable-msbc" = true; # Better call quality
            "bluez5.enable-hw-volume" = true; # Hardware volume control
          };
        };
        #
        # "11-bluetooth-policy" = {
        #   "wireplumber.settings" = {
        #     "bluetooth.autoswitch-to-headset-profile" = false; # Keep A2DP profile
        #   };
        # };
        #
        # USB Audio Device Renaming
        "51-home-headset-rename" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "alsa_output.usb-0b0e_Jabra_Link_380_50C275557279-00.iec958-stereo";
                }
              ];
              actions = {
                "update-props" = {
                  "node.nick" = "Jabra Headset";
                  "node.description" = "Jabra Headset";
                };
              };
            }
          ];
        };

        "51-home-speakers-rename" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "alsa_card.usb-KTMicro_KT_USB_Audio_2021-06-07-0000-0000-0000--00";
                }
                {
                  "node.name" = "alsa_output.usb-KTMicro_KT_USB_Audio_2021-06-07-0000-0000-0000--00.analog-stereo";
                }
              ];
              actions = {
                "update-props" = {
                  "node.nick" = "Home Speakers";
                  "node.description" = "Home Speakers";
                };
              };
            }
          ];
        };

        # Disable HDMI outputs on onboard audio
        "52-alsa-disable" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink";
                }
                {
                  "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI2__sink";
                }
                {
                  "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI3__sink";
                }
              ];
              actions = {
                "update-props" = {
                  "node.disabled" = true;
                };
              };
            }
          ];
        };

        # Onboard audio and HP monitor configuration
        "52-onboard-rename" = {
          "monitor.alsa.rules" = [
            # Rename onboard audio device
            {
              matches = [
                {
                  "media.class" = "Audio/Device";
                  "device.name" = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic";
                }
              ];
              actions = {
                "update-props" = {
                  "device.nick" = "Onboard Audio";
                  "device.description" = "Onboard Audio";
                };
              };
            }
            # Rename onboard speaker output
            {
              matches = [
                {
                  "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";
                }
              ];
              actions = {
                "update-props" = {
                  "node.nick" = "Onboard Audio";
                  "node.description" = "Onboard Audio";
                };
              };
            }
            # Rename HP monitor microphone
            {
              matches = [
                {
                  "node.name" = "alsa_input.usb-Generic_HP_Z40c_G3_USB_Audio-00.iec958-stereo";
                }
              ];
              actions = {
                "update-props" = {
                  "node.nick" = "Hp Monitor mic";
                  "node.description" = "Hp Monitor mic";
                };
              };
            }
            # Disable HP monitor audio output
            {
              matches = [
                {
                  "node.name" = "alsa_output.usb-Generic_HP_Z40c_G3_USB_Audio-00.iec958-stereo";
                }
              ];
              actions = {
                "update-props" = {
                  "node.disabled" = true;
                };
              };
            }
          ];
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    pipewire
    wireplumber
  ];
}
