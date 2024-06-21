# Tapendium CI Utilities Buildkite Plugin

A Buildkite library plugin with common utilities used in CI.

## Utilities

### publish-languages

Publish languages.json file to EventBridge

```yml
steps:
  - command: publish-languages event_bus_name service_name user_id event_detail_type
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
```

```yml
steps:
  - command: publish-languages
    env:
      # optional defaults to frontend/locale/en.json
      PUBLISH_LANGUAGES_FILE_PATH: en.json
      # optional defaults to en
      PUBLISH_LANGUAGES_LANGUAGE_CODE: en
      PUBLISH_LANGUAGES_EVENT_BUS_NAME: busname
      # service_name is inferred from repo URL
      PUBLISH_LANGUAGES_EVENT_USER_ID: userid
      PUBLISH_LANGUAGES_DETAIL_TYPE: languages.updated
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
```

### publish-features

Publish features.json file to EventBridge

```yml
steps:
  - command: publish-features event_bus_name service_name user_id event_detail_type
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
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
      - tapendium/tap-ci-utils#v0.6.0: ~
```

### validate-features

Validate features.json matches expected format

```yml
steps:
  - command: validate-features
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
```

### Deploy-websocket

Deployed Websocket when updating websocket api

```yml
steps:
  - command: deploy-websocket
    env:
      MATRIX: maxtrix
      API_GATEWAY_WEBSOCKETAPIID: apigatewayID
      DESCRIPTION: description
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
```

### install-npm-packages

Install npm packages if node_modules has not been restored from cache

```yml
steps:
  - commands:
      - cd backend
      - install-npm-packages
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
```

### hash-dir

Generate a single MD5 hash of a directory and its contents

```yml
steps:
  - commands:
      - hash-dir frontend
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
```

### publish-npm-package

Bump the version and publish an npm package if the package contents have changed. The default version bump is a "patch" but all version changes supported by npm can be used [npm version](https://docs.npmjs.com/cli/v10/commands/npm-version)

**Publish a patch version**

```yml
steps:
  - commands:
      - cd lib
      - publish-npm-package
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
```

**Publish a major version**

```yml
steps:
  - commands:
      - cd lib
      - publish-npm-package major
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
```

**Dry run package publish of minor versino**

```yml
steps:
  - commands:
      - cd lib
      - publish-npm-package -n minor
    plugins:
      - tapendium/tap-ci-utils#v0.6.0: ~
```
