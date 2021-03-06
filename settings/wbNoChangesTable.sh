# No recording of data in wb_changes table (for dispatching to clients)
# https://doc.wikimedia.org/Wikibase/master/php/md_docs_topics_options.html#autotoc_md261
echo "\$wgWBRepoSettings['useChangesTable'] = false;" >> LocalSettings.php
