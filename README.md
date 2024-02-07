# Tapendium CI Utilities Buildkite Plugin

A Buildkite library plugin with common utilities used in CI.

## Utilities

### publish-features

Publish features.json file to EventBridge

```bash
publish-features event_bus_name service_name user_id event_detail_type
```

```bash
export PUBLISH_FEATURES_EVENT_BUS_NAME=busname
# service_name is inferred from repo URL
export PUBLISH_FEATURES_EVENT_USER_ID=userid
export PUBLISH_FEATURES_DETAIL_TYPE=features.updated

publish-features
```

### validate-features

Validate features.json matches expected format

```bash
validate-features
```
