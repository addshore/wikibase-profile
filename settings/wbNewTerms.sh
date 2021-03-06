# 1.35 maintains 2 terms storage backends, only write to one of them!
# These write might all end up in the job queue anyway, so this may have no difference affect in comparison to mwNoJobs
echo "\$wgWBRepoSettings['tmpPropertyTermsMigrationStage'] = MIGRATION_NEW;" >> LocalSettings.php
echo "\$wgWBRepoSettings['tmpItemTermsMigrationStages'] = [ 'max' => MIGRATION_NEW ];" >> LocalSettings.php
echo "\$wgWBRepoSettings['tmpItemSearchMigrationStage'] = MIGRATION_NEW;" >> LocalSettings.php
echo "\$wgWBRepoSettings['tmpPropertySearchMigrationStage'] = MIGRATION_NEW;" >> LocalSettings.php
