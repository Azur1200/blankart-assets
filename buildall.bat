del out\main.pk3
del out\mappatch.pk3
python pk3make.py -z build\main.txt
python pk3make.py -z build\mappatch.txt
xxh3sum out\main.pk3
xxh3sum out\mappatch.pk3
