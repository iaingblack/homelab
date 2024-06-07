Really good guide

http://virtualizationhowto.com/2021/06/automated-windows-server-2022-packer-build?utm_source=pocket_shared

Example from this: https://github.com/joefitzgerald/packer-windows

packer init backend.pkr.hcl
packer   build --only=virtualbox-iso --var iso_url="C:/ISOs/en-us_windows_server_version_23h2_updated_may_2024_x64_dvd_744fe423.iso"  .\windows_2022.json^C
