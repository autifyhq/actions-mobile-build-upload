<p align="center">
  <a href="https://github.com/autifyhq/actions-mobile-build-upload"><img alt="actions-mobile-build-upload status" src="https://github.com/autifyhq/actions-mobile-build-upload/workflows/test/badge.svg"></a>
</p>

# Upload build to Autify for Mobile

Upload a build file to Autify for Mobile.

See our official documentation to get started: https://help.autify.com/mobile/docs/github-actions-integration

## Usage

### Upload iOS build file to Autify for Mobile

```yaml
- uses: autifyhq/actions-mobile-build-upload@v2
  with:
    access-token: ${{ secrets.AUTIFY_MOBILE_ACCESS_TOKEN }}
    workspace-id: AAA
    build-path: /path/to/your-app.app
```

### Upload Android build file to Autify for Mobile

```yaml
- uses: autifyhq/actions-mobile-build-upload@v2
  with:
    access-token: ${{ secrets.AUTIFY_MOBILE_ACCESS_TOKEN }}
    workspace-id: AAA
    build-path: /path/to/your-app.apk
```

## Options

```yaml
access-token:
  required: true
  description: "Access token of Autify for Mobile."
workspace-id:
  required: true
  description: "Workspace ID to upload the build file."
build-path:
  required: true
  description: "File path to the iOS app (*.app) or Android app (*.apk)."
autify-path:
  required: false
  default: "autify"
  description: "A path to `autify`. If set, this action will not install autify-cli."
autify-cli-installer-url:
  required: false
  default: "https://autify-cli-assets.s3.amazonaws.com/autify-cli/channels/stable/install-cicd.bash"
  description: "Autify CLI installer URL"
```

## Outputs

```yaml
exit-code:
  description: "Exit code of autify-cli. 0 means succeeded."
log:
  description: "Log of stdout and stderr."
build-id:
  description: "Returned build id in the workspace."
```

## Migrations

### v2 from v1

Most of the case, v2 is compatible with v1 inputs. Please try to migrate to v2 because v1 is no more maintained.
