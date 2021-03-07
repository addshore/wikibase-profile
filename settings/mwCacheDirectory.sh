## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publicly accessible from the web.
echo "\$wgCacheDirectory = \"\$IP/cache\";" >> LocalSettings.php
