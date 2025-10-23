rm out/main.pk3
rm out/mappatch.pk3
python3 pk3make.py build/main.txt -j$(nproc)
python3 pk3make.py build/mappatch.txt -j$(nproc)
xxhsum -H3 out/main.pk3
xxhsum -H3 out/mappatch.pk3
