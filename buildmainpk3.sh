rm out/main.pk3
python3 pk3make.py build/main.txt -j$(nproc)
xxhsum -H3 out/main.pk3
