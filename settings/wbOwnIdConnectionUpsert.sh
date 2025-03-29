# Use a separate DB connection for ID allocation to reduce contention
# And try upserting...
echo "\$wgWBRepoSettings['idGeneratorSeparateDbConnection'] = true;" >> LocalSettings.php
echo "\$wgWBRepoSettings['idGenerator'] = 'mysql-upsert';" >> LocalSettings.php
