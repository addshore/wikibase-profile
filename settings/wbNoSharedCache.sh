# Do not use a shared Wikibase cache, this is mainly useful for multi site setups? or reads?
# https://doc.wikimedia.org/Wikibase/master/php/md_docs_topics_options.html#common_sharedCacheType
echo "\$wgWBRepoSettings['useChangessharedCacheTypeTable'] = CACHE_NONE;" >> LocalSettings.php
