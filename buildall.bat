del out\main.pk3
del out\blanmusic.pk3
python pk3make.py build\main.txt -j%NUMBER_OF_PROCESSORS%
python pk3make.py build\blanmusic.txt -j%NUMBER_OF_PROCESSORS%
xxh3sum out\main.pk3
xxh3sum out\blanmusic.pk3
