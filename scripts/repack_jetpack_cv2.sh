#!/bin/bash

set -e
set -o pipefail

script_dir=$(
  cd "$(dirname "$0")"
  pwd
)

py_version="${1:-3.8}"
cv2_path="${2:-/usr/lib/python${py_version}/dist-packages/cv2}"
cv_version="${3:-4.5.4}"
version_postfix="${4:-l4t}"

pack_version="${cv_version}+${version_postfix}"

echo "Packing cv2 ${pack_version} for Python ${py_version}..."

# check if py_version is in cv2_path
if [[ ! "${cv2_path}" =~ "${py_version}" ]]; then
    echo "Error: ${py_version} is not in ${cv2_path}"
    exit 1
fi

# convert py_version to py_version_num, eg 3.8 -> 38
py_version_num=$(echo "${py_version}" | sed 's/\.//g')

if [ ! -d "${cv2_path}" ]; then
    echo "Error: ${cv2_path} does not exist"
    exit 1
fi

pack_dir="${script_dir}/jetpack_cv2"

# remove old pack dir if exists
if [ -d "${pack_dir}" ]; then
    rm -rf "${pack_dir}"
fi

mkdir "${pack_dir}"

# copy cv2 to pack dir
cp -r "${cv2_path}" "${pack_dir}"

# create dir opencv_python-{version}.dist-info
dist_info_dir="${pack_dir}/opencv_python-${pack_version}.dist-info"
mkdir "${dist_info_dir}"

# copy $script_dir/metadata/METADATA to dist_info_dir
cp "${script_dir}/metadata/jetpack/METADATA" "${dist_info_dir}"

# copy $script_dir/metadata/WHEEL to dist_info_dir
cp "${script_dir}/metadata/jetpack/WHEEL" "${dist_info_dir}"

# replace {version} in METADATA
sed -i "s/{version}/${pack_version}/g" "${dist_info_dir}/METADATA"

# replace {py_version} in METADATA
sed -i "s/{py_version}/${py_version_num}/g" "${dist_info_dir}/METADATA"

# replace {py_version} in WHEEL
sed -i "s/{py_version}/${py_version_num}/g" "${dist_info_dir}/WHEEL"

cd "${script_dir}"
wheel pack jetpack_cv2
