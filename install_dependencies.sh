#!/bin/bash

#  install_dependencies.sh
#
#  :description: post-build script to install wakatime python package
#
#  :maintainer: WakaTime <support@wakatime.com>
#  :license: BSD, see LICENSE for more details.
#  :website: https://wakatime.com/

set -e
set -x

url="https://codeload.github.com/wakatime/wakatime/zip/master"
install_dir="$HOME/Library/Application Support/TextMate/PlugIns/WakaTime.tmplugin/Contents/Resources"
zip_file="$install_dir/wakatime-master.zip"
installed_package="$install_dir/wakatime-master"

cd "$install_dir"

echo "Downloading wakatime package to $zip_file ..."
curl "$url" -o "$zip_file"

echo "Unzipping wakatime.zip to $installed_package ..."
unzip -o "$zip_file"

rm "$zip_file"

echo "Finished installing wakatime cli."
