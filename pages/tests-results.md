---
title: Tests Summary
author: {{site.author}}
menu_item: true
menu_title: Tests
category: reports
child_category: surefire_reports
layout: default
order: 3
---

# JUnit Reports
{% for version in site.data.versions %}
- [{{version.version}}](pages/versions/tests-results-{{version.version}}.html)
{% endfor %}