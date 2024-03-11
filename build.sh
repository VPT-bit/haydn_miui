#!/bin/bash
export PATH=$PATH:$(pwd)/bin/
stock_rom="$1"
work_dir=$(pwd)
mkdir -p ${work_dir}/tmp > /dev/null 2>&1
mkdir -p ${work_dir}/rom/images > /dev/null 2>&1

# Import functions
source functions.sh

# Setup
sudo apt update -y > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1
sudo apt-get install -y git zip unzip tar axel python3-pip zipalign apktool apksigner xmlstarlet busybox p7zip-full openjdk-8-jre android-sdk-libsparse-utils > /dev/null 2>&1 && blue "Setup Successful" || error "Setup Failed"
pip3 install ConfigObj > /dev/null 2>&1
sudo chmod 777 -R *

# unzip rom
blue "Downloading ROM..."
axel -n $(nproc) $stock_rom > /dev/null 2>&1 && green "Downloaded ROM" || error "Failed to Download ROM"
stock_rom=$(basename $stock_rom)
if unzip -l ${stock_rom} | grep -q "payload.bin"; then
    blue "Detected PAYLOAD.BIN, Unpacking ROM..."
    unzip ${stock_rom} payload.bin -d rom/images/ > /dev/null 2>&1 && green "Unpacked ROM" || error "Failed to Unzip Rom"
    rm -rf ${stock_rom}
else
    error "Unsupported"
    exit
fi

# extract payload.bin & image
cd rom/images
blue "Extracting Payload.bin"
payload-dumper-go -o . payload.bin > /dev/null 2>&1 && green "Extracted Payload.bin" || error "Failed To Extract Payload.bin"
rm -rf payload.bin
blue "Extracting Image Partition..."
for pname in system product vendor; do
    extract.erofs -i ${pname}.img -x > /dev/null 2>&1
    rm -rf ${pname}.img
    [ -d ${pname} ] && green "Extracted ${pname} [EROFS] Successfully" || error "Failed to Extract ${pname} "
done
vbmeta-disable-verification vbmeta.img > /dev/null 2>&1 && green "Disable Vbmeta Successfully" || error "Failed To Disable Verification"

# add gpu driver
<<<<<<< HEAD
cd ${work_dir}
blue "Installing Gpu Driver..."
echo /system/system/lib/egl/libVkLayer_ADRENO_qprofiler.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib64/egl/libVkLayer_ADRENO_qprofiler.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib64/libEGL.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib64/libGLESv1_CM.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib64/libGLESv2.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib64/libGLESv3.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib64/libvulkan.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib/libEGL.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib/libGLESv1_CM.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib/libGLESv2.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib/libGLESv3.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
echo /system/system/lib/libvulkan.so u:object_r:system_lib_file:s0 >> rom/images/config/system_file_contexts
###
echo /vendor/etc/sphal_libraries.txt u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/libEGL_adreno.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/libGLESv2_adreno.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/libadreno_app_profiles.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/libq3dtools_adreno.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/libllvm-qgl.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/libllvm-glnext.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/libllvm-qcom.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/hw/vulkan.adreno.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/egl/ u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/ u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/libVkLayer_ADRENO_qprofiler.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libVkLayer_ADRENO_qprofiler.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libEGL_adreno.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libGLESv2_adreno.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libadreno_app_profiles.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libq3dtools_adreno.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/hw/vulkan.adreno.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libllvm-qgl.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libllvm-glnext.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libllvm-qcom.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/egl/ u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libdmabufheap.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib/libdmabufheap.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libCB.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/notgsl.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
echo /vendor/lib64/libadreno_utils.so u:object_r:same_process_hal_file:s0 >> rom/images/config/vendor_file_contexts
###
cp -rf patch_rom/vendor/* rom/images/vendor > /dev/null 2>&1 && green "Add GPU Driver Successfully" || error "Failed To Add Gpu Driver"
=======
>>>>>>> 213fc95b6f1537c039b33af3ba4bec89a20c006b

# add leica camera
cd tmp
blue "Installing Leica Camera..."
axel -n $(nproc) https://github.com/VPT-bit/Patch_China_Rom_Haydn/releases/download/alpha/HolyBearMiuiCamera.apk > /dev/null 2>&1
mv HolyBearMiuiCamera.apk MiuiCamera.apk > /dev/null 2>&1
cd ${work_dir}
mv -v tmp/MiuiCamera.apk rom/images/product/priv-app/MiuiCamera > /dev/null 2>&1 && green "Add Leica Camera Successfully" || error "Failed To Add Leica Camera"
rm -rf tmp/*
    
# add launcher mod
mv -v patch_rom/product/priv-app/MiuiHomeT/MiuiHomeT.apk rom/images/product/priv-app/MiuiHomeT > /dev/null 2>&1
mv -v patch_rom/product/etc/permissions/privapp_whitelist_com.miui.home.xml rom/images/product/etc/permissions > /dev/null 2>&1
mv -v patch_rom/system/system/etc/permissions/privapp_whitelist_com.miui.home.xml rom/images/system/system/etc/permissions > /dev/null 2>&1
mv -v patch_rom/product/overlay/MiuiPocoLauncherResOverlay.apk rom/images/product/overlay > /dev/null 2>&1
[ -f rom/images/system/system/etc/permissions/privapp_whitelist_com.miui.home.xml ] && green "Add Launcher Mod Successfully" || error "Fail"

# add xiaomi.eu extension
mkdir -p rom/images/product/priv-app/XiaomiEuExt > /dev/null 2>&1
mv -v patch_rom/product/priv-app/XiaomiEuExt/XiaomiEuExt.apk rom/images/product/priv-app/XiaomiEuExt > /dev/null 2>&1
mv -v patch_rom/product/etc/permissions/privapp_whitelist_eu.xiaomi.ext.xml rom/images/product/etc/permissions > /dev/null 2>&1
[ -f rom/images/product/priv-app/XiaomiEuExt/XiaomiEuExt.apk ] && green "Add XiaomiEuExt Successfully" || error "Fail"

# patch performance
mv -v patch_rom/product/pangu/system/app/Joyose/Joyose.apk rom/images/product/pangu/system/app/Joyose > /dev/null 2>&1
mv -v patch_rom/system/system/app/PowerKeeper/PowerKeeper.apk rom/images/system/system/app/PowerKeeper > /dev/null 2>&1
green "Patch Performance Successfully"

# add overlay
blue "Building the Overlay..."
git clone https://github.com/VPT-bit/overlay.git > /dev/null 2>&1
cd overlay
sudo chmod +x build.sh > /dev/null 2>&1
build.sh > /dev/null 2>&1
cd ${work_dir}
mv -v overlay/output/* rom/images/product/overlay > /dev/null 2>&1 && green "Overlay Build Has Been Completed" || error "Failed To Add Overlay"
rm -rf overlay

# disable apk protection
blue "Disabling Apk Protection..."
cd ${work_dir}
cp -rf rom/images/system/system/framework/services.jar services.jar > /dev/null 2>&1
remove_apk_protection && green "Disable Apk Protection Successfully" || error "Failed To Disable Apk Protection"
cp -rf tmp/services.jar rom/images/system/system/framework/services.jar > /dev/null 2>&1

# patch .prop and .xml
cd ${work_dir}

# product .prop
sed -i 's/<item>120<\/item>/<item>120<\/item>\n\t\t<item>90<\/item>/g' rom/images/product/etc/device_features/haydn.xml

# system .prop
echo debug.hwui.renderer=vulkan >> rom/images/system/system/build.prop
echo bhlnk.hypervs.overlay=true >> rom/images/system/system/build.prop

# vendor .prop
sed -i 's|ro\.hwui\.use_vulkan=|ro\.hwui\.use_vulkan=true|' rom/images/vendor/build.prop
echo persist.vendor.mi_sf.optimize_for_refresh_rate.enable=1 >> rom/images/vendor/build.prop
echo ro.vendor.mi_sf.ultimate.perf.support=true >> rom/images/vendor/build.prop
echo ro.surface_flinger.use_content_detection_for_refresh_rate=false >> rom/images/vendor/build.prop
echo ro.surface_flinger.set_touch_timer_ms=0 >> rom/images/vendor/build.prop
echo ro.surface_flinger.set_idle_timer_ms=0 >> rom/images/vendor/build.prop
green "Patching .prop and .xml completed"

# font
mv -v patch_rom/system/system/fonts/MiSansVF.ttf rom/images/system/system/fonts > /dev/null 2>&1 && green "Replace Font Successfully" || error "Failed To Change Font"

# debloat
cp -r rom/images/product/data-app/MIMediaEditor tmp > /dev/null 2>&1
cp -r rom/images/product/data-app/MIUICleanMaster tmp > /dev/null 2>&1
cp -r rom/images/product/data-app/MIUINotes tmp > /dev/null 2>&1
cp -r rom/images/product/data-app/MiuiScanner tmp > /dev/null 2>&1
cp -r rom/images/product/data-app/MIUIScreenRecorder tmp > /dev/null 2>&1
cp -r rom/images/product/data-app/MIUISoundRecorderTargetSdk30 tmp > /dev/null 2>&1
cp -r rom/images/product/data-app/MIUIWeather tmp > /dev/null 2>&1
cp -r rom/images/product/data-app/SmartHome tmp > /dev/null 2>&1
cp -r rom/images/product/data-app/ThirdAppAssistant tmp > /dev/null 2>&1
rm -rf rom/images/product/data-app/* > /dev/null 2>&1
rm -rf rom/images/product/app/AnalyticsCore > /dev/null 2>&1
rm -rf rom/images/product/app/MSA > /dev/null 2>&1
rm -rf rom/images/product/priv-app/MIUIBrowser > /dev/null 2>&1
rm -rf rom/images/product/priv-app/MIUIQuickSearchBox > /dev/null 2>&1
cp -r tmp/* rom/images/product/data-app > /dev/null 2>&1 && green "Debloat Completed" || error "Failed To Debloat"
rm -rf tmp/*

# patch context and fsconfig
for pname in system product vendor; do
    python3 bin/contextpatch.py rom/images/${pname} rom/images/config/${pname}_file_contexts && check_contexts=1 || check_contexts=0
    python3 bin/fspatch.py rom/images/${pname} rom/images/config/${pname}_fs_config && check_fs=1 || check_fs=0
    if [ $check_contexts == "1" ] && [ $check_fs == "1" ]; then
        green "Patching ${pname} Contexts and Fs_config Completed"
    else
        error "Patching ${pname} Contexts and Fs_config Failed"
    fi
done
cd rom/images
for pname in system product vendor; do
    option=`sed -n '3p' config/${pname}_fs_options | cut -c28-`
    mkfs.erofs $option > /dev/null 2>&1
    rm -rf ${pname}
    mv ${pname}_repack.img ${pname}.img > /dev/null 2>&1
    [ -f ${pname}.img ] && green "Packaging ${pname} [EROFS] Is Complete" || error "Packaging ${pname} Failed"
done

# pack super
system_size=`stat -c '%n %s' system.img | cut -d ' ' -f 2`
system_ext_size=`stat -c '%n %s' system_ext.img | cut -d ' ' -f 2`
product_size=`stat -c '%n %s' product.img | cut -d ' ' -f 2`
vendor_size=`stat -c '%n %s' vendor.img | cut -d ' ' -f 2`
odm_size=`stat -c '%n %s' odm.img | cut -d ' ' -f 2`
mi_ext_size=`stat -c '%n %s' mi_ext.img | cut -d ' ' -f 2`
sum_size=`echo "$system_size + $system_ext_size + $product_size + $vendor_size + $odm_size + $mi_ext_size" | bc`
###
blue "Packing Super..."
command="--metadata-size 65536 --super-name super --metadata-slots 3 --device super:9126805504 --group qti_dynamic_partitions_a:$sum_size --partition product_a:readonly:$product_size:qti_dynamic_partitions_a --image product_a=product.img --partition system_a:readonly:$system_size:qti_dynamic_partitions_a --image system_a=system.img --partition system_ext_a:readonly:$system_ext_size:qti_dynamic_partitions_a --image system_ext_a=system_ext.img --partition vendor_a:readonly:$vendor_size:qti_dynamic_partitions_a --image vendor_a=vendor.img --partition odm_a:readonly:$odm_size:qti_dynamic_partitions_a --image odm_a=odm.img --partition mi_ext_a:readonly:$mi_ext_size:qti_dynamic_partitions_a --image mi_ext_a=mi_ext.img --group qti_dynamic_partitions_b:0 --partition product_b:readonly:0:qti_dynamic_partitions_b --partition system_b:readonly:0:qti_dynamic_partitions_b --partition system_ext_b:readonly:0:qti_dynamic_partitions_b --partition vendor_b:readonly:0:qti_dynamic_partitions_b --partition odm_b:readonly:0:qti_dynamic_partitions_b --partition mi_ext_b:readonly:0:qti_dynamic_partitions_b --virtual-ab --sparse --output super"
lpmake ${command} > /dev/null 2>&1
[ -f super ] && green "Super [Virtual-A/B] Has Been Packaged" || error "Packaging Super Failed"

###
blue "Super Is Being Compressed..."
zstd --rm super -o super.zst > /dev/null 2>&1
[ -f super.zst ] && green "Super Has Been Compressed" || error "Compress Super Failed"
for part in product system system_ext vendor odm mi_ext;
do
    rm -rf ${part}.img
done

# cleanup
cd ${work_dir}
blue "Packing and Cleaning Up..."
cp -rf patch_rom/flash/* rom
rm -rf rom/images/config
cd rom
zip -r haydn_rom.zip * > /dev/null 2>&1
cd ${work_dir}
mv -v rom/haydn_rom.zip . > /dev/null 2>&1
rm -rf rom
[ -f haydn_rom.zip ] && green "Done, Prepare to Upload..." || error "Failed"

