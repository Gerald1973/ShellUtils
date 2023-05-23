#!/bin/bash
input_dir="/mnt/data_02/tmp/video_in"
output_dir="/mnt/data_02/tmp/video_out"
video_in_suffix="mp4"
video_out_suffix="mp4"
current_dir=$(pwd)
cd "${input_dir}"
video_files=(*.${video_in_suffix})
cd "${current_dir}"
number_of_videos=${#video_files[@]}
width=640
height=480
echo "Number of files: ${number_of_videos}"
for ((i=0; i < $number_of_videos; i++));do
    echo ${video_files[i]}
    input_file_name=${video_files[i]}
    # ffmpeg -y -hwaccel cuda -i input.file output.file
    output_file_name=${input_file_name%.${video_in_suffix}}.${video_out_suffix}
    echo ${output_file_name}
    ffmpeg -hwaccel cuda -i "${input_dir}/${input_file_name}" -vf "scale=${width}:${height},setsar=1:1" "${output_dir}/${output_file_name}"
done