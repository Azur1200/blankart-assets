rm out/blanmusic.pk3
python3 pk3make.py build/blanmusic.txt -j$(nproc)
xxhsum -H3 out/blanmusic.pk3
