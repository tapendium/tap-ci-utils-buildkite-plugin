# Tapendium CI Utilities Buildkite Plugin

A Buildkite library plugin with common utilities used in CI.

## Utilities

### publish-features

Publish features.json file to EventBridge

```yml
steps:
  - command: publish-features event_bus_name service_name user_id event_detail_type
    plugins:
      - tapendium/tap-ci-utils#v0.2.1: ~
```

```yml
steps:
  - command: publish-features
    env:
      PUBLISH_FEATURES_EVENT_BUS_NAME: busname
      # service_name is inferred from repo URL
      PUBLISH_FEATURES_EVENT_USER_ID: userid
      PUBLISH_FEATURES_DETAIL_TYPE: features.updated
    plugins:
      - tapendium/tap-ci-utils#v0.2.1: ~
```

### validate-features

Validate features.json matches expected format

```yml
steps:
  - command: validate-features
    plugins:
      - tapendium/tap-ci-utils#v0.2.1: ~
```
