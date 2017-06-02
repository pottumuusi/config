#!/bin/bash

# Following texts helped me
# https://www3.ntu.edu.sg/home/ehchua/programming/java/JavaNativeInterface.html
# http://jonisalonen.com/2012/calling-c-from-java-is-easy/

program_name=$1
lib_name=$2
jdkpath=$3

assert_file_exists() {
    local file_to_check=$1
    if [ ! -e $file_to_check ] ; then
        echo "Could not find file: $file_to_check. Exiting..."
        exit 1
    fi
}

assert_directory_exists() {
    local directory_to_check=$1
    if [ ! -e $directory_to_check ] ; then
        echo "Could not find directory: $directory_to_check. Exiting..."
        exit 1
    fi
}

help_and_exit() {
    echo -e "\nrun.sh: Build and run a JNI example."
    echo "Usage: run.sh program_name lib_name [path_to_jdk]"
    echo -e "\nWill search for JDK if path to JDK is not provided by user."
    echo -e "Run from directory which contains .java and .c file to build.\n"
    exit 0
}

print_done() {
    echo -n  -e "[ D     ]\r"
    sleep 0.05
    echo -n  -e "[ Do    ]\r"
    sleep 0.05
    echo -n  -e "[ Don   ]\r"
    sleep 0.05
    echo -n  -e "[ Done  ]\r"
    sleep 0.05
    echo -n  -e "[ Done! ]\r"
    sleep 0.1
    echo -n  -e "[       ]\r"
    sleep 0.1
    echo -n  -e "[ Done! ]\r"
    sleep 0.1
    echo -n  -e "[       ]\r"
    sleep 0.1
    echo  -e "[ Done! ]\n"
}

if [ "$program_name" == "" -a "$lib_name" == "" -a "$jdkpath" == "" ] ; then
    help_and_exit
fi

if [ "-h" == "$program_name" -o "--help" == "$program_name" ] ; then
    help_and_exit
fi

assert_file_exists "$program_name.java"
assert_file_exists "$program_name.c"

# Remove ending "/" from user provided path if such exists
jdkpath=$(echo $jdkpath | sed 's/\/$//')
echo "corrected jdkpath: $jdkpath"

# Substitute "/include/jni.h" at the end of line with ""
no_include='s/\/include\/jni.h$//'

if [ -z "$jdkpath" ] ; then
    echo -e "\nGive password to search for JDK beginning from root directory"
    jdkpath=$(sudo find / -name jni.h | grep -i "jdk" | sed $no_include)
    assert_directory_exists "$jdkpath"
fi

echo "Found JDK path: $jdkpath"

if [ -z "$jdkpath" -o -z "$program_name" -o -z "$lib_name" ] ; then
    echo "program_name: $program_name"
    echo "lib_name: $lib_name"
    echo "jdkpath: $jdkpath"
    echo "Error: missing information for build. Exiting..."
    exit 1
fi

echo "Compiling $program_name.java..."
javac $program_name.java

echo "Creating C/C++ header file for the native method(s)..."
javah $program_name

echo "Generating shared library lib$lib_name.so..."
export JAVA_HOME="$jdkpath"

# From man gcc
# ============
#
# -c
# The -c option says not to run the linker.
#
# -fpic
# Generate position-independent code (PIC) suitable for use in a
# shared library, if supported for the target machine.
#
# If the GOT size for the linked executable exceeds a machine-specific
# maximum size, you get an error message from the linker indicating that
# -fpic does not work; in that case, recompile with -fPIC instead.
gcc -fPIC -c $program_name.c -I $JAVA_HOME/include -I $JAVA_HOME/include/linux/

# From man gcc
# ============
#
# -Wl,option
# Pass option as an option to the linker.
#
# -shared
# Produce a shared object which can then be linked with other objects
# to form an executable.
gcc $program_name.o -shared -o lib$lib_name.so -Wl,-soname,$lib_name

print_done
read -p "Press enter to run $program_name "

export LD_LIBRARY_PATH=$PWD
java $program_name
