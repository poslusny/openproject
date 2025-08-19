---
title: OpenProject 15.5.1
sidebar_navigation:
    title: 15.5.1
release_version: 15.5.1
release_date: 2025-05-05
---

# OpenProject 15.5.1

Release date: 2025-05-05

We released OpenProject [OpenProject 15.5.1](https://community.openproject.org/versions/2195).
The release contains several bug fixes and we recommend updating to the newest version.
In these Release Notes, we will give an overview of important feature changes.
At the end, you will find a complete list of all changes and bug fixes.

<!--more-->

## Bug fixes and changes

<!-- Warning: Anything within the below lines will be automatically removed by the release script -->
<!-- BEGIN AUTOMATED SECTION -->

- Bugfix: PDF Export: Strikethrough formatting in tables is not applied \[[#62231](https://community.openproject.org/wp/62231)\]
- Bugfix: Non-working days can be choosen via date field \[[#62525](https://community.openproject.org/wp/62525)\]
- Bugfix: &#39;Related to&#39; relations is added when user adds any other type of relations \[[#62587](https://community.openproject.org/wp/62587)\]
- Bugfix: Cannot start /usr/bin/openproject run web after Upgrade to 15.3.2 \[[#62764](https://community.openproject.org/wp/62764)\]
- Bugfix: ActiveRecord::RecordNotFound in WorkPackages::DatePickerController#show \[[#62834](https://community.openproject.org/wp/62834)\]
- Bugfix: ActiveRecord::RecordNotUnique on RecurringMeetingsController#update \[[#63381](https://community.openproject.org/wp/63381)\]
- Bugfix: SystemStackError on api/v3/projects with larger pageSize (e.g. 1000) \[[#63498](https://community.openproject.org/wp/63498)\]
- Bugfix: Error 500 on deleting Categories \[[#63502](https://community.openproject.org/wp/63502)\]
- Bugfix: All /assets/frontend requests return 404 not found \[[#63503](https://community.openproject.org/wp/63503)\]
- Bugfix: 500 when sending empty workflow \[[#63514](https://community.openproject.org/wp/63514)\]
- Bugfix: ActiveRecord::RecordNotFound on WorkPackageRelationsController#destroy \[[#63521](https://community.openproject.org/wp/63521)\]
- Bugfix: Git authentication fails after upgrading to OP 15.5.0 \[[#63534](https://community.openproject.org/wp/63534)\]
- Bugfix: Error 500 when changing duration days of successor to zero  \[[#63598](https://community.openproject.org/wp/63598)\]
- Bugfix: PDF timesheet: Error for TimeEntry with hours set to nil \[[#63600](https://community.openproject.org/wp/63600)\]
- Bugfix: OpenProject 15.5.0: Error 500 when clicking diff in a repository \[[#63604](https://community.openproject.org/wp/63604)\]
- Bugfix: Ordering by version/assignee/responsible and sorting by custom field of type version/user at the same time fails \[[#63671](https://community.openproject.org/wp/63671)\]
- Bugfix: IFC conversion failing in helm installation \[[#63762](https://community.openproject.org/wp/63762)\]

<!-- END AUTOMATED SECTION -->
<!-- Warning: Anything above this line will be automatically removed by the release script -->

## Contributions
A big thanks to our Community members for reporting bugs and helping us identify and provide fixes.
This release, special thanks for reporting and finding bugs go to Sven Kunze, Dan Goodliffe, Robin Reichenbach, Nicolas Salguero.
