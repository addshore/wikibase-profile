# Use a seperate DB connection for ID allocation to reduce contention
# https://doc.wikimedia.org/Wikibase/master/php/md_docs_topics_options.html#repo_idGeneratorSeparateDbConnection
echo "\$wgWBRepoSettings['idGeneratorSeparateDbConnection'] = true;" >> LocalSettings.php