---
layout: default
title:  "Releases"
---

# Releases

{% for release in releases -%}
## [Version {{ release.version }}](https://github.com/jbmorley/fileaway/releases/tag/macOS_{{ release.version }}){% if not release.is_released %} (Unreleased){% endif %}
{% for section in release.sections %}
### {{ section.title }}

{% for change in section.changes | reverse -%}
- {{ change.description }}{% if change.scope %}{{ change.scope }}{% endif %}
{% endfor %}{% endfor %}
{% endfor %}
