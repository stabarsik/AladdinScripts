#!/bin/bash

game="Agent"
game_path="agent"

#game="IndianSpirit"
#game_path="IS"

#game="GodsOfWar"
#game_path="GodsOfWar"

#game="OceanPower"
#game_path="ocean_power"

#game="Robin"
#game_path="robin"

sleep_time=15

echo "Pack $game resources..."

echo -e "\tDelete old archive"
pushd ../ALDdata > /dev/null
rm ${game}_res1.dat &> /dev/null
rm ${game}_res2.dat &> /dev/null
popd > /dev/null

echo -e "\tDelete atlas $game"
pushd ../ALDdata/Textures/$game_path/atlas > /dev/null
rm -rf *.atl *.dds *.tga
popd > /dev/null

echo -e "\tFirst run $game"
pushd ../aladdin/ > /dev/null
QtProject/bin/ALD_d $game &> /dev/null & pid=$!
echo -e "\t\t$sleep_time second sleep"
sleep $sleep_time
echo -e "\t\tKill $game"
kill $pid
popd > /dev/null

echo -e "\tMake atlas"
pushd ../ALDdata/Textures > /dev/null
~/workdir/release/utils/atlasmake ../atlas_out.txt $game_path/atlas/atlas.atl $game_path/atlas/page_%% 10000.0 &> /dev/null
popd > /dev/null

echo -e "\t\tConvert atlas to dds"
pushd ../ALDdata/Textures/$game_path/atlas > /dev/null
for i in *.tga; do
	echo -e "\t\t\tCompress $i"
	#nvcompress -bc3 -nomips ${i} > /dev/null
	wine ~/.wine/drive_c/Program\ Files/NVIDIA\ Corporation/DDS\ Utilities/nvdxt.exe -file ${i} -nomipmap -dxt5 -overwrite -outsamedir
done;
rm *.tga
echo -e "\t\tPatch atlas.atl"
sed -i 's/.tga/.dds/g' atlas.atl
popd > /dev/null

echo -e "\tSecond run $game"
pushd ../aladdin > /dev/null
QtProject/bin/ALD_d $game &> /dev/null & pid=$!
echo -e "\t\t$sleep_time second sleep"
sleep $sleep_time
echo -e "\t\tKill $game"
kill $pid
popd > /dev/null

echo -e "\tPack datafiles"
pushd ../ALDdata > /dev/null
cat res_out.txt | sort | uniq > ${game}_res.txt
~/workdir/aladdin/QtProject/tools/tool_tps_resources ${game}_res.txt 1 &> /dev/null
mv f1.dat ../release/ALDdata/${game}_res1.dat
mv f2.dat ../release/ALDdata/${game}_res2.dat
popd > /dev/null

echo -e "\tDownload new execute file"
pushd bin > /dev/null
wget -q ftp://devel_ksi:develTgy65Yt@ftp.ksi.ru/Release_Versions/ALD/recent_bin/ALD -O ALD
chmod +x ALD
popd > /dev/null

echo -e "Done!"

echo -e "Delete tmp files"
pushd ../ALDdata/Textures/$game_path/atlas > /dev/null
rm -rf *.atl *.dds *.tga
popd > /dev/null

echo -e "Test build"
pushd bin > /dev/null
./ALD $game
popd > /dev/null
echo -e "Bye!"
