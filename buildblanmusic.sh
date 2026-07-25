rm out/blanmusic.pk3
python3 pk3make.py build/blanmusic.txt -j$(nproc) -z
xxhsum -H3 out/blanmusic.pk3
