cd ../../../..

export ANDROID_ROOT=$(pwd)
export KERNEL_TOP=$ANDROID_ROOT/kernel/sony/msm-4.14
export KERNEL_TMP=$ANDROID_ROOT/out/kernel-tmp
export CC=$ANDROID_ROOT/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/
export CC32=$ANDROID_ROOT/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/
export CLANG=$ANDROID_ROOT/prebuilts/clang/host/linux-x86/clang-r353983c/bin/
export PATH=$CC:$CC32:$CLANG:$PATH

# Mkdtimg tool
export MKDTIMG=$ANDROID_ROOT/out/host/linux-x86/bin/mkdtimg

# Build command
export BUILD="make O=$KERNEL_TMP ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- CROSS_COMPILE_ARM32=arm-linux-androideabi- -j$(nproc)"

# Copy prebuilt kernel
export CP_BLOB="cp $KERNEL_TMP/arch/arm64/boot/Image.gz-dtb $KERNEL_TOP/common-kernel/kernel-dtb"

# Check if mkdtimg tool exists
if [ ! -f $MKDTIMG ]; then
    echo "mkdtimg: File not found!"
    echo "Building mkdtimg"
    export ALLOW_MISSING_DEPENDENCIES=true
    make mkdtimg
fi

YOSHINO="lilac maple poplar"
NILE="discovery pioneer voyager"
GANGES="kirin mermaid"
TAMA="akari apollo akatsuki"
KUMANO="bahamut griffin"
SEINE="pdx201"

PLATFORMS="yoshino nile ganges tama kumano seine"

cd $KERNEL_TOP/kernel

echo "================================================="
echo "Your Environment:"
echo "ANDROID_ROOT: ${ANDROID_ROOT}"
echo "KERNEL_TOP  : ${KERNEL_TOP}"
echo "KERNEL_TMP  : ${KERNEL_TMP}"

for platform in $PLATFORMS; do \

case $platform in
loire)
    DEVICE=$LOIRE;
    DTBO="false";;
tone)
    DEVICE=$TONE;
    DTBO="false";;
yoshino)
    DEVICE=$YOSHINO;
    DTBO="false";;
nile)
    DEVICE=$NILE;
    DTBO="false";;
ganges)
    DEVICE=$GANGES;
    DTBO="false";;
tama)
    DEVICE=$TAMA;
    DTBO="true";;
kumano)
    DEVICE=$KUMANO;
    DTBO="true";;
seine)
    DEVICE=$SEINE;
    DTBO="true";;
esac

for device in $DEVICE; do \
    ret=$(rm -rf ${KERNEL_TMP} 2>&1);
    ret=$(mkdir -p ${KERNEL_TMP} 2>&1);
    if [ ! -d ${KERNEL_TMP} ] ; then
        echo "Check your environment";
        echo "ERROR: ${ret}";
        exit 1;
    fi

    echo "================================================="
    echo "Platform -> ${platform} :: Device -> $device"
    ret=$(${BUILD} aosp_$platform"_"$device\_defconfig 2>&1);
    case "$ret" in
        *"error"*|*"ERROR"*) echo "ERROR: $ret"; exit 1;;
    esac

    echo "The build may take up to 10 minutes. Please be patient ..."
    echo "Building new kernel image ..."
    echo "Loggin to $KERNEL_TMP/build_log_${device}"
    $BUILD >$KERNEL_TMP/build_log_${device} 2>&1;

    echo "Copying new kernel image ..."
    ret=$(${CP_BLOB}-${device} 2>&1);
    case "$ret" in
        *"error"*|*"ERROR"*) echo "ERROR: $ret"; exit 1;;
    esac
    if [ $DTBO = "true" ]; then
        $MKDTIMG create $KERNEL_TOP/common-kernel/dtbo-$device\.img `find $KERNEL_TMP/arch/arm64/boot/dts -name "*.dtbo"`
    fi
done
done

echo "================================================="
echo "Clean up environment"
echo "Done!"
unset ANDROID_ROOT
unset KERNEL_TOP
unset KERNEL_CFG
unset KERNEL_TMP
unset BUILD
