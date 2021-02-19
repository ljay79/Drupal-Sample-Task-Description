<?php

# Change the following to be TRUE if you want to work with enabled css- and js-aggregation:
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;

/*
 * Cache
 */
#$settings['cache']['default']                    = 'cache.backend.redis';
$settings['cache']['default']                    = 'cache.backend.null';
# Uncomment these lines to disable the render cache and disable dynamic page cache:
$settings['cache']['bins']['render']             = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
$settings['cache']['bins']['page']               = 'cache.backend.null';

$settings['file_chmod_directory'] = 0775;
$settings['file_chmod_file'] = 0775;
