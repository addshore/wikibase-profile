#!/bin/bash

set -x

if [ ! -f entrypoint-done.txt ]; then

    # Wait for the DB to be ready?
    /wait-for-it.sh mysql:3306 -t 300
    sleep 1
    /wait-for-it.sh mysql:3306 -t 300

    # Install MediaWiki
    php maintenance/install.php --server="http://localhost:8181" --scriptpath= --dbtype mysql --dbuser wikiuse --dbpass sqlpass --dbserver mysql --lang en --dbname my_wiki --pass LongCIPass123 SiteName CIUser

    # Load Wikibase defaults
    echo "require_once \"\$IP/extensions/Wikibase/vendor/autoload.php\";" >> LocalSettings.php
    echo "require_once \"\$IP/extensions/Wikibase/repo/Wikibase.php\";" >> LocalSettings.php
    echo "require_once \"\$IP/extensions/Wikibase/repo/ExampleSettings.php\";" >> LocalSettings.php

    # And allow anon users to create properties (so we don't need to log in)
    echo "\$wgGroupPermissions['*']['property-create'] = true;" >> LocalSettings.php

    # Update MediaWiki & Extensions
    php maintenance/update.php --quick

    # Run extra entry point stuff for this test (such as config changes)
    /code-settings.sh

    # Mark the entrypoint as having run!
    echo "entrypoint done!" > entrypoint-done.txt

fi

# Run apache
apache2-foreground