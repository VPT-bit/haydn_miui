#!/bin/bash

# Define color output function
error() {
    if [ "$#" -eq 2 ]; then
        
        if [[ "$LANG" == zh_CN* ]]; then
            echo -e \[$(date +%d/%m-%T)\] "\033[1;31m"$1"\033[0m"
        elif [[ "$LANG" == en* ]]; then
            echo -e \[$(date +%d/%m-%T)\] "\033[1;31m"$2"\033[0m"
        else
            echo -e \[$(date +%d/%m-%T)\] "\033[1;31m"$2"\033[0m"
        fi
    elif [ "$#" -eq 1 ]; then
        echo -e \[$(date +%d/%m-%T)\] "\033[1;31m"$1"\033[0m"
    else
        echo "Usage: error <Chinese> <English>"
    fi
}

yellow() {
    if [ "$#" -eq 2 ]; then
        
        if [[ "$LANG" == zh_CN* ]]; then
            echo -e \[$(date +%d/%m-%T)\] "\033[1;33m"$1"\033[0m"
        elif [[ "$LANG" == en* ]]; then
            echo -e \[$(date +%d/%m-%T)\] "\033[1;33m"$2"\033[0m"
        else
            echo -e \[$(date +%d/%m-%T)\] "\033[1;33m"$2"\033[0m"
        fi
    elif [ "$#" -eq 1 ]; then
        echo -e \[$(date +%d/%m-%T)\] "\033[1;33m"$1"\033[0m"
    else
        echo "Usage: yellow <Chinese> <English>"
    fi
}

blue() {
    if [ "$#" -eq 2 ]; then
        
        if [[ "$LANG" == zh_CN* ]]; then
            echo -e \[$(date +%d/%m-%T)\] "\033[1;34m"$1"\033[0m"
        elif [[ "$LANG" == en* ]]; then
            echo -e \[$(date +%d/%m-%T)\] "\033[1;34m"$2"\033[0m"
        else
            echo -e \[$(date +%d/%m-%T)\] "\033[1;34m"$2"\033[0m"
        fi
    elif [ "$#" -eq 1 ]; then
        echo -e \[$(date +%d/%m-%T)\] "\033[1;34m"$1"\033[0m"
    else
        echo "Usage: blue <Chinese> <English>"
    fi
}

green() {
    if [ "$#" -eq 2 ]; then
        if [[ "$LANG" == zh_CN* ]]; then
            echo -e \[$(date +%d/%m-%T)\] "\033[1;32m"$1"\033[0m"
        elif [[ "$LANG" == en* ]]; then
            echo -e \[$(date +%d/%m-%T)\] "\033[1;32m"$2"\033[0m"
        else
            echo -e \[$(date +%d/%m-%T)\] "\033[1;32m"$2"\033[0m"
        fi
    elif [ "$#" -eq 1 ]; then
        echo -e \[$(date +%d/%m-%T)\] "\033[1;32m"$1"\033[0m"
    else
        echo "Usage: green <Chinese> <English>"
    fi
}

#Check for the existence of the requirements command, proceed if it exists, or abort otherwise.
exists() {
    command -v "$1" > /dev/null 2>&1
}

abort() {
    error "--> Missing $1 abort! please run ./setup.sh first (sudo is required on Linux system)"
    error "--> 命令 $1 缺失!请重新运行setup.sh (Linux系统sudo ./setup.sh)"
    exit 1
}

check() {
    for b in "$@"; do
        exists "$b" || abort "$b"
    done
}


# Replace Smali code in an APK or JAR file, without supporting resource patches.
# $1: Target APK/JAR file
# $2: Target Smali file (supports relative paths for Smali files)
# $3: Value to be replaced
# $4: Replacement value
patch_smali() {
    targetfilefullpath=$(find rom/images -type f -name $1)
    targetfilename=$(basename $targetfilefullpath)
    if [ -f $targetfilefullpath ];then
        yellow "正在修改 $targetfilename" "Modifying $targetfilename"
        foldername=${targetfilename%.*}
        rm -rf tmp/$foldername/
        mkdir -p tmp/$foldername/
        cp -rf $targetfilefullpath tmp/$foldername/
        7z x -y tmp/$foldername/$targetfilename *.dex -otmp/$foldername >/dev/null
        for dexfile in tmp/$foldername/*.dex;do
            smalifname=${dexfile%.*}
            smalifname=$(echo $smalifname | cut -d "/" -f 3)
            java -jar bin/apktool/baksmali.jar d --api "30" ${dexfile} -o tmp/$foldername/$smalifname 2>&1 || error " Baksmaling 失败" "Baksmaling failed"
        done
        if [[ $2 == *"/"* ]];then
            targetsmali=$(find tmp/$foldername/*/$(dirname $2) -type f -name $(basename $2))
        else
            targetsmali=$(find tmp/$foldername -type f -name $2)
        fi
        if [ -f $targetsmali ];then
            smalidir=$(echo $targetsmali |cut -d "/" -f 3)
            yellow "I: 开始patch目标 ${smalidir}" "Target ${smalidir} Found"
            search_pattern=$3
            repalcement_pattern=$4
            if [[ $5 == 'regex' ]];then
                 sed -i "/${search_pattern}/c\\${repalcement_pattern}" $targetsmali
            else
            sed -i "s/$search_pattern/$repalcement_pattern/g" $targetsmali
            fi
            java -jar bin/apktool/smali.jar a --api "30" tmp/$foldername/${smalidir} -o tmp/$foldername/${smalidir}.dex > /dev/null 2>&1 || error " Smaling 失败" "Smaling failed"
            pushd tmp/$foldername/ >/dev/null || exit
            7z a -y -mx0 -tzip $targetfilename ${smalidir}.dex  > /dev/null 2>&1 || error "修改$targetfilename失败" "Failed to modify $targetfilename"
            popd >/dev/null || exit
            yellow "修补$targetfilename 完成" "Fix $targetfilename completed"
            if [[ $targetfilename == *.apk ]]; then
                yellow "检测到apk，进行zipalign处理。。" "APK file detected, initiating ZipAlign process..."
                rm -rf ${targetfilefullpath}

                # Align moddified APKs, to avoid error "Targeting R+ (version 30 and above) requires the resources.arsc of installed APKs to be stored uncompressed and aligned on a 4-byte boundary" 
                zipalign -p -f -v 4 tmp/$foldername/$targetfilename ${targetfilefullpath} > /dev/null 2>&1 || error "zipalign错误，请检查原因。" "zipalign error,please check for any issues"
                yellow "apk zipalign处理完成" "APK ZipAlign process completed."
                yellow "复制APK到目标位置：${targetfilefullpath}" "Copying APK to target ${targetfilefullpath}"
            else
                yellow "复制修改文件到目标位置：${targetfilefullpath}" "Copying file to target ${targetfilefullpath}"
                cp -rf tmp/$foldername/$targetfilename ${targetfilefullpath}
            fi
        fi
    fi

}

unlock_device_feature() {
    feature=$2
    if [[ ! -z "$1" ]]; then
        comment=$1
    else
        comment="Whether enable $feature feature"
    fi

    if ! grep -q "$feature" rom/images/product/etc/device_features/${base_rom_code}.xml;then
        sed -i "/<features>/a\\\t<!-- ${comment} -->\n\t<bool name=\"${feature}\">true</bool> " rom/images/product/etc/device_features/${base_rom_code}.xml
    else
        sed -i "s/<bool name=\"$feature\">.*<\/bool>/<bool name=\"$feature\">true<\/bool>/" rom/images/product/etc/device_features/${base_rom_code}.xml
    fi
}

#check if a prperty is avaialble
is_property_exists () {
    if [ $(grep -c "$1" "$2") -ne 0 ]; then
        return 0
    else
        return 1
    fi
}

# Function to update netlink in build.prop
update_netlink() {
  local netlink_version=$1
  local prop_file=$2

  if grep -q "ro.millet.netlink" "$prop_file"; then
    blue "找到ro.millet.netlink修改值为$netlink_version" "millet_netlink propery found, changing value to $netlink_version"
    sed -i "s/ro.millet.netlink=.*/ro.millet.netlink=$netlink_version/" "$prop_file"
  else
    blue "PORTROM未找到ro.millet.netlink值,添加为$netlink_version" "millet_netlink not found in portrom, adding new value $netlink_version"
    echo -e "ro.millet.netlink=$netlink_version\n" >> "$prop_file"
  fi
}


# Function to remove apk protection
remove_apk_protection()
{
	
	dir=$(pwd)
	repS="python3 $dir/bin/apktool/strRep.py"
	
	jar_util() 
	{
		cd $dir
		#binary
		if [[ $3 == "fw" ]]; then 
			bak="java -jar $dir/bin/apktool/baksmali.jar d"
			sma="java -jar $dir/bin/apktool/smali.jar a"
		else
			bak="java -jar $dir/bin/baksmali-2.5.2.jar d"
			sma="java -jar $dir/bin/smali-2.5.2.jar a"
		fi
	
		if [[ $1 == "d" ]]; then
			echo -ne "====> Patching $2 : "
			if [[ -f $dir/services.jar ]]; then
				sudo cp $dir/services.jar $dir/jar_temp
				sudo chown $(whoami) $dir/jar_temp/$2
				unzip $dir/jar_temp/$2 -d $dir/jar_temp/$2.out  >/dev/null 2>&1
				if [[ -d $dir/jar_temp/"$2.out" ]]; then
					rm -rf $dir/jar_temp/$2
					for dex in $(find $dir/jar_temp/"$2.out" -maxdepth 1 -name "*dex" ); do
							if [[ $4 ]]; then
								if [[ ! "$dex" == *"$4"* ]]; then
									$bak $dex -o "$dex.out"
									[[ -d "$dex.out" ]] && rm -rf $dex
								fi
							else
								$bak $dex -o "$dex.out"
								[[ -d "$dex.out" ]] && rm -rf $dex		
							fi
	
					done
				fi
			fi
		else 
			if [[ $1 == "a" ]]; then 
				if [[ -d $dir/jar_temp/$2.out ]]; then
					cd $dir/jar_temp/$2.out
					for fld in $(find -maxdepth 1 -name "*.out" ); do
						if [[ $4 ]]; then
							if [[ ! "$fld" == *"$4"* ]]; then
								$sma $fld -o $(echo ${fld//.out})
								[[ -f $(echo ${fld//.out}) ]] && rm -rf $fld
							fi
						else 
							$sma $fld -o $(echo ${fld//.out})
							[[ -f $(echo ${fld//.out}) ]] && rm -rf $fld	
						fi
					done
					7za a -tzip -mx=0 $dir/jar_temp/$2_notal $dir/jar_temp/$2.out/. >/dev/null 2>&1
					#zip -r -j -0 $dir/jar_temp/$2_notal $dir/jar_temp/$2.out/.
					zipalign 4 $dir/jar_temp/$2_notal $dir/jar_temp/$2
					if [[ -f $dir/jar_temp/$2 ]]; then
						sudo cp -rf $dir/jar_temp/$2 $dir/tmp
						final_dir="$dir/module/*"
						#7za a -tzip "$dir/services_patched_$(date "+%d%m%y").zip" $final_dir
						echo "Success"
						rm -rf $dir/jar_temp/$2.out $dir/jar_temp/$2_notal 
					else
						echo "Fail"
					fi
				fi
			fi
		fi
	}
	
	
	services() {
	
		lang_dir="$dir/module/lang"
	
		jar_util d "services.jar" fw
	
		#patch signature
	
		s0=$(find -name "PermissionManagerServiceImpl.smali")
		[[ -f $s0 ]] && $repS $dir/bin/signature/PermissionManagerServiceImpl/updatePermissionFlags.config.ini $s0
		[[ -f $s0 ]] && $repS $dir/bin/signature/PermissionManagerServiceImpl/shouldGrantPermissionBySignature.config.ini $s0
		[[ -f $s0 ]] && $repS $dir/bin/signature/PermissionManagerServiceImpl/revokeRuntimePermissionNotKill.config.ini $s0
		[[ -f $s0 ]] && $repS $dir/bin/signature/PermissionManagerServiceImpl/revokeRuntimePermission.config.ini $s0
		[[ -f $s0 ]] && $repS $dir/bin/signature/PermissionManagerServiceImpl/grantRuntimePermission.config.ini $s0
	
		s1=$(find -name "PermissionManagerServiceStub.smali")
		[[ -f $s1 ]] && echo $(cat $dir/bin/signature/PermissionManagerServiceStub/onAppPermFlagsModified.config.ini) >> $s1
		
		s2=$(find -name "ParsingPackageUtils.smali")
		[[ -f $s2 ]] && $repS $dir/bin/signature/ParsingPackageUtils/getSigningDetails.config.ini $s2
	
		s3=$(find -name 'PackageManagerService$PackageManagerInternalImpl.smali' )
		[[ -f $s3 ]] && $repS $dir/bin/signature/'PackageManagerService$PackageManagerInternalImpl'/isPlatformSigned.config.ini $s3
	
		s4=$(find -name "PackageManagerServiceUtils.smali")
		[[ -f $s4 ]] && $repS $dir/bin/signature/PackageManagerServiceUtils/verifySignatures.config.ini $s4
	
		s5=$(find -name "ReconcilePackageUtils.smali")
		[[ -f $s5 ]] && $repS $dir/bin/signature/ReconcilePackageUtils/reconcilePackages.config.ini $s5
	
		s6=$(find -name "ScanPackageUtils.smali")
		[[ -f $s6 ]] && $repS $dir/bin/signature/ScanPackageUtils/assertMinSignatureSchemeIsValid.config.ini $s6
		#[[ -f $s6 ]] && $repS $dir/bin/signature/ScanPackageUtils/applyPolicy.configs.ini $s6
		
		jar_util a "services.jar" fw
	}
	
	if [[ ! -d $dir/jar_temp ]]; then
	
		mkdir $dir/jar_temp
		
	fi
	
	services

}

