# All of the lightweight settings in one!

# No jobs run after requests
# https://www.mediawiki.org/wiki/Manual:Job_queue#Performance_issue
echo "\$wgJobRunRate = 0;" >> LocalSettings.php

# 1.35 maintains 2 terms storage backends, only write to one of them!
# These write might all end up in the job queue anyway, so this may have no difference affect in comparison to mwNoJobs
echo "\$wgWBRepoSettings['tmpPropertyTermsMigrationStage'] = MIGRATION_NEW;" >> LocalSettings.php
echo "\$wgWBRepoSettings['tmpItemTermsMigrationStages'] = [ 'max' => MIGRATION_NEW ];" >> LocalSettings.php
echo "\$wgWBRepoSettings['tmpItemSearchMigrationStage'] = MIGRATION_NEW;" >> LocalSettings.php
echo "\$wgWBRepoSettings['tmpPropertySearchMigrationStage'] = MIGRATION_NEW;" >> LocalSettings.php

# No recording of data in wb_changes table (for dispatching to clients)
# https://doc.wikimedia.org/Wikibase/master/php/md_docs_topics_options.html#autotoc_md261
echo "\$wgWBRepoSettings['useChangesTable'] = false;" >> LocalSettings.php

# Use a seperate DB connection for ID allocation to reduce contention
# https://doc.wikimedia.org/Wikibase/master/php/md_docs_topics_options.html#repo_idGeneratorSeparateDbConnection
echo "\$wgWBRepoSettings['idGeneratorSeparateDbConnection'] = true;" >> LocalSettings.php

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publicly accessible from the web.
echo "\$wgCacheDirectory = \"\$IP/cache\";" >> LocalSettings.php
