packer build \
  --only=vbox-iso \
  --var vhv_enable=true \
  --var iso_url=c:/ISOs/en-us_windows_server_version_23h2_updated_may_2024_x64_dvd_744fe423.iso \
  windows-2022.json