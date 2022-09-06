package:
	shards build --production --release --without-development
	zip -q -X -r firebolt.alfredworkflow icon.png bin/firebolt-alfred-docs-workflow info.plist
