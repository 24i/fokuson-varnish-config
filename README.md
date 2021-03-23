# FokusOn Varnish Config #

## Introduction ##
This repository contains Varnish configuration and install files to use with fokusOn. The files are targeted Varnish 6.0LTS but should work with later releases. Operators of fokusOn should fork this repository to keep track of local changes specific to their installation.

## Structure of the repository ##
The default VCL files are published in the *vcl* folder while the *install* folder holds customized system-related config-files that is used during installation. Please refer to Nordijas Varnish 6 install documentation for details. If you don't have that, please contact Nordija Professional Services.

## How to use this repository ##
We recommend that you fork this repository and create branches for each of your environments (Production, staging, test, development etc). This allows you to track your local changes for each environment, and to merge upstream changes from Nordija in to your local changes. Nordija strives to make sure that version specific changes[^1]  will  be prominent in the commit history of this respository (which constitutes the changelog), and/or in comments next to the relevant sections in the config file. 

When installing Varnish from scratch in a new environment, you should always use the latest tagged version. All tags will be made on the *master* branch, unless specifically noted elsewhere. If you are looking to update your Varnish configuration as part of or in preparation of upgrades of other components, then please thoroughly read trough the release notes of all involved components (including this repository) to ensure that the changes you deploy are compatible with each other.

As always, you should deploy changes to dev, test and staging environments before deploying to production. Any issue that arises because a configuration has not been tested in at least one non-production environment before deployment to production, can not be handled by Nordija as a SLA issue.

[^1]: Changes specific to a certain version of either fokusOn or another component like Unified-Search or Ads-system.
