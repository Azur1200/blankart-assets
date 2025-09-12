rm out/main.pk3
rm out/mappatch.pk3
python pk3make.py -z build/main.txt
python pk3make.py -z build/mappatch.txt
xxhsum -H3 out/main.pk3
xxhsum -H3 out/mappatch.pk3
