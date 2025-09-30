rm out/main.pk3
python pk3make.py build/main.txt -j$(nproc)
xxh3sum out/main.pk3
