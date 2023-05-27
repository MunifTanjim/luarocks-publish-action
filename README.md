# LuaRocks Publish - GitHub Action

🌛 Publish to LuaRocks using GitHub Actions

## Preparation

**Rockspec Template:**

Create a `<packge-name>-dev-1.rockspec` file on your repository root:

```lua
rockspec_format = "3.0"
package = "dummy.lua"
version = "dev-1"
source = {
  url = "git+https://github.com/MunifTanjim/dummy.lua.git",
  tag = nil,
}
description = {
  summary = "Dummy Package to test LuaRocks!",
  detailed = [[
    Dummy Package to test LuaRocks!
  ]],
  license = "MIT",
  homepage = "https://github.com/MunifTanjim/dummy.lua",
  issues_url = "https://github.com/MunifTanjim/dummy.lua/issues",
  maintainer = "Munif Tanjim (https://muniftanjim.dev)",
  labels = {},
}
build = {
  type = "builtin",
}
```

This will be used as a template for your package rockspec.

> **Note**
>
> - `version` must be `"dev-1"`
> - `source.tag` must be `nil`

## Configuration

|       input        | description                                          |
| :----------------: | ---------------------------------------------------- |
|   `lua_version`    | Lua version to install _(required)_                  |
|  `luajit_version`  | LuaJIT version to install _(optional)_               |
| `luarocks_version` | LuaRocks version to install _(required)_             |
|       `name`       | Package name _(optional, default: repository name )_ |
|     `version`      | Version to publish _(optional, default: `'dev'`)_    |
|     `api_key`      | LuaRocks API Key _(required)_                        |
|      `force`       | Force publish _(optional, default: `'false'`)_       |

Check [action.yml](./action.yml).

## Usage

### Basic

```yml
# .github/workflows/publish.yml

name: Publish

on:
  push:
    tags:
      - "[0-1].[0-9]+.[0-9]+"

jobs:
  publish:
    name: publish
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: LuaRocks Publish
        uses: MunifTanjim/luarocks-publish-action@v1
        with:
          lua_version: 5.1.5
          luarocks_version: 3.9.1
          api_key: ${{ secrets.LUAROCKS_API_KEY }}
```

### Workflow Dispatch

```yml
# .github/workflows/publish.yml

name: Publish

on:
  push:
    tags:
      - "[0-1].[0-9]+.[0-9]+"
  workflow_dispatch:
    inputs:
      version:
        description: Version to publish
        required: false
        type: string
      force:
        description: Force publish
        required: false
        default: false
        type: boolean

jobs:
  publish:
    name: publish
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: LuaRocks Publish
        uses: MunifTanjim/luarocks-publish-action@v1
        with:
          lua_version: 5.1.5
          luarocks_version: 3.9.1
          version: ${{ inputs.version }}
          api_key: ${{ secrets.LUAROCKS_API_KEY }}
          force: ${{ inputs.force }}
```

**Trigger using [GitHub CLI](https://cli.github.com):**

```sh
gh workflow run --repo MunifTanjim/dummy.lua publish.yml -f version=dev -f force=false
```

**Trigger using [Release Please Action](https://github.com/marketplace/actions/release-please-action):**

```yml
# .github/workflows/ci.yml

name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  release:
    name: release
    if: ${{ github.ref == 'refs/heads/main' }}
    runs-on: ubuntu-latest
    permissions:
      actions: write
      contents: write
      pull-requests: write
    steps:
      - uses: google-github-actions/release-please-action@v3
        id: release
        with:
          release-type: simple
          package-name: dummy.lua
          bump-minor-pre-major: true
          pull-request-title-pattern: "chore: release ${version}"
          include-v-in-tag: false
      - name: Trigger Publish
        if: ${{ steps.release.outputs.release_created }}
        env:
          GH_TOKEN: ${{ github.token }}
          TAG_NAME: ${{ steps.release.outputs.tag_name }}
        run: |
          gh workflow run --repo ${GITHUB_REPOSITORY} publish.yml -f version=${TAG_NAME}
```

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.
