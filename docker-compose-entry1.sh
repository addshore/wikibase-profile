#!/bin/bash

set -x

if [ ! -f entrypoint-done.txt ]; then

    # Wait for the DB to be ready?
    /wait-for-it.sh mysql:3306 -t 300
    sleep 1
    /wait-for-it.sh mysql:3306 -t 300

    # Install MediaWiki
    php maintenance/install.php --server="http://localhost:8181" --scriptpath= --dbtype mysql --dbuser wikiuser --dbpass sqlpass --dbserver mysql --lang en --dbname my_wiki --pass LongCIPass123 SiteName CIUser

    # Load Wikibase defaults
    echo "require_once \"\$IP/extensions/Wikibase/repo/Wikibase.php\";" >> LocalSettings.php
    echo "require_once \"\$IP/extensions/Wikibase/repo/ExampleSettings.php\";" >> LocalSettings.php

    # If we get errors make them easier to debug
    echo "\$wgShowExceptionDetails = true;" >> LocalSettings.php
    # Don't rate limit the anon user
    echo "\$wgGroupPermissions['*']['noratelimit'] = true;" >> LocalSettings.php
    # And allow anon users to create properties (so we don't need to log in)
    echo "\$wgGroupPermissions['*']['property-create'] = true;" >> LocalSettings.php

    # Update MediaWiki & Extensions
    php maintenance/update.php --quick

    # Run extra entry point stuff for this test (such as config changes)
    /code-settings.sh

    # Build the localisation cache ahead of makinng bulk requests (as building it can cause issues)
    php maintenance/rebuildLocalisationCache.php --lang en
    # And disable any recaching on web requests
    echo "\$wgLocalisationCacheConf['manualRecache'] = true;" >> LocalSettings.php

    # Mark the entrypoint as having run!
    echo "entrypoint done!" > entrypoint-done.txt

fi

# Run apache
apache2-foreground