rm out/main.pk3
rm out/mappatch.pk3
rm out/blanmusic.pk3
python3 pk3make.py build/main.txt -j$(nproc) -z
python3 pk3make.py build/mappatch.txt -j$(nproc) -z 
python3 pk3make.py build/blanmusic.txt -j$(nproc) -z
xxhsum -H3 out/main.pk3
xxhsum -H3 out/mappatch.pk3
xxhsum -H3 out/blanmusic.pk3
