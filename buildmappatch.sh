rm out/mappatch.pk3
python pk3make.py build/mappatch.txt -j$(nproc)
xxh3sum out/mappatch.pk3
