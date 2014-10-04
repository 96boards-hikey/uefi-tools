#!/usr/bin/python

import sys, os, argparse, subprocess, multiprocessing, platform

tools_path = os.path.dirname(os.path.realpath(sys.argv[0])) + '/'

# Mapping table edk2 arch name/uname -m
uname_edk2 = {'armv7l': 'ARM',
              'aarch64': 'AARCH64',
              'x86_64': 'X64'}

def set_cross_compile(arch):
    cross_compilers = {'ARM': 'arm-linux-gnueabihf-',
                       'AARCH64': 'aarch64-linux-gnu-',
                       'X64': 'x86_64-linux-gnu-'}

    envcross = os.environ.get('CROSS_COMPILE_' + arch)
    if envcross != None:
        cross = envcross
    elif arch == uname_edk2[platform.machine()]:
        cross = ""
    elif arch in cross_compilers:
        cross = cross_compilers[arch]
    else:
        print "no cross compiler available for '" + arch + "'"
        return False

    os.environ['CROSS_COMPILE'] = cross
    return True

def build_platform(plat):
    print "building " + plat

    plat_arch = subprocess.Popen([tools_path + "parse-platforms.py", "get", "-p", plat, "-o",  "arch"], stdout=subprocess.PIPE).communicate()[0].strip()

    if set_cross_compile(plat_arch) != True:
        return False

    print "Using cross compiler: " + os.environ.get('CROSS_COMPILE')

    return True

output = subprocess.Popen([tools_path + "parse-platforms.py", "list"], stdout=subprocess.PIPE).communicate()[0]
available_platforms = sorted(output.split())
del output

parser = argparse.ArgumentParser(description='Parses platform configuration for Linaro UEFI build scripts.')

parser.add_argument('-a', '--atfdir', help='path to ARM Trusted Firmware source directory', default="../arm-trusted-firmware")
parser.add_argument('-b', '--build', action='append', help='profiles to build for every target (can be specified multiple times for multiple profiles)', default=[])
parser.add_argument('-D', '--define', action='append', help='pass additional predefines to EDK2 build system', default=[])
parser.add_argument('platforms', action="store", nargs='+', help='Specify platforms to build, or \'all\' to build all of them. Available are: ' + ', '.join(available_platforms))

args = parser.parse_args()
if args.build == []:
    args.build = ["RELEASE"]

if args.platforms == ["all"]:
    args.platforms = available_platforms

#print args

if hasattr(os, "sysconf") and os.sysconf_names.has_key("SC_NPROCESSORS_ONLN"):
    cpu_count = os.sysconf("SC_NPROCESSORS_ONLN")
else:
    cpu_count = multiprocessing.cpu_count()

#print "num_cpus:", cpu_count

for plat in args.platforms:
    build_platform(plat)
