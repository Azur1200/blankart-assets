del out\main.pk3
del out\mappatch.pk3
del out\blanmusic.pk3
python pk3make.py build\main.txt -j%NUMBER_OF_PROCESSORS% -z -f
python pk3make.py build\mappatch.txt -j%NUMBER_OF_PROCESSORS% -z -f
python pk3make.py build\blanmusic.txt -j%NUMBER_OF_PROCESSORS% -z -f
xxh3sum out\main.pk3
xxh3sum out\mappatch.pk3
xxh3sum out\blanmusic.pk3
