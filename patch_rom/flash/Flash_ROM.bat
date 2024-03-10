@echo off
if exist bin\platform-tools-windows\fastboot.exe PATH=%PATH%;bin\platform-tools-windows
setlocal enabledelayedexpansion
echo.
echo Modified by Tg: @vpt_19
echo.
echo Decompressing super.img...
zstd --rm -d images/super.zst -o images/super.img
echo.
echo Decompression completed
echo.
set /p wipeData="Do you need to clear data? (y/n): "
echo.
echo Flashing process starts...
echo.
fastboot flash xbl_config_a images/xbl_config.img
fastboot flash xbl_config_b images/xbl_config.img
fastboot flash xbl_a images/xbl.img
fastboot flash xbl_b images/xbl.img
fastboot flash vendor_boot_a images/vendor_boot.img
fastboot flash vendor_boot_b images/vendor_boot.img
fastboot --disable-verity --disable-verification flash vbmeta_system_a images/vbmeta_system.img
fastboot --disable-verity --disable-verification flash vbmeta_system_b images/vbmeta_system.img
fastboot --disable-verity --disable-verification flash vbmeta_a images/vbmeta.img
fastboot --disable-verity --disable-verification flash vbmeta_b images/vbmeta.img
fastboot flash uefisecapp_a images/uefisecapp.img
fastboot flash uefisecapp_b images/uefisecapp.img
fastboot flash tz_a images/tz.img
fastboot flash tz_b images/tz.img
fastboot flash shrm_a images/shrm.img
fastboot flash shrm_b images/shrm.img
fastboot flash qupfw_a images/qupfw.img
fastboot flash qupfw_b images/qupfw.img
fastboot flash modem_a images/modem.img
fastboot flash modem_b images/modem.img
fastboot flash keymaster_a images/keymaster.img
fastboot flash keymaster_b images/keymaster.img
fastboot flash imagefv_a images/imagefv.img
fastboot flash imagefv_b images/imagefv.img
fastboot flash hyp_a images/hyp.img
fastboot flash hyp_b images/hyp.img
fastboot flash featenabler_a images/featenabler.img
fastboot flash featenabler_b images/featenabler.img
fastboot flash dtbo_a images/dtbo.img
fastboot flash dtbo_b images/dtbo.img
fastboot flash dsp_a images/dsp.img
fastboot flash dsp_b images/dsp.img
fastboot flash devcfg_a images/devcfg.img
fastboot flash devcfg_b images/devcfg.img
fastboot flash cpucp_a images/cpucp.img
fastboot flash cpucp_b images/cpucp.img
fastboot flash bluetooth_a images/bluetooth.img
fastboot flash bluetooth_b images/bluetooth.img
fastboot flash boot_a images\boot.img
fastboot flash boot_b images\boot.img
fastboot flash aop_a images/aop.img
fastboot flash aop_b images/aop.img
fastboot flash abl_a images/abl.img
fastboot flash abl_b images/abl.img
if exist images\cust.img fastboot flash cust images/cust.img
if exist images\super.img fastboot flash super images/super.img
echo.
echo Please wait for the flashing process to complete and reboot automatically
echo.
if /i "!wipeData!" == "y" (
	fastboot erase userdata
	fastboot erase metadata
)
fastboot set_active a
fastboot reboot
pause
