# No jobs run after requests
# https://www.mediawiki.org/wiki/Manual:Job_queue#Performance_issue
echo "\$wgJobRunRate = 0;" >> LocalSettings.php
