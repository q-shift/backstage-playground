# quarkus-console

Welcome to the quarkus-console plugin!

_This plugin was created through the Backstage CLI_

## HowTo guide

The section describes the different steps followed to create the plugin and integrates it with kubernetes/ocp

### Foundation

- New plugin created using command ` yarn new --select plugin` and using as id `quarkus-console`
- Example generated has been renamed to `src/components/QuarkusConsole` and `src/components/QuarkusConsoleFetch`
- Type definition and example have been refactyored to return a `TableColumn` with dummy records
- New module added to the `packages/app/packages.json` => `"@internal/plugin-quarkus-console": "^0.1.0",`
- Quarkus icon created (QuarkusIcon.tsx) using `MUI: SvgIcon & SvgIconProps)`
- New `<SidebarItem icon={QuarkusIcon} to="quarkus" text="Quarkus" />` added to `src/components/Root/Root.tsx`
- New `<EntityLayout.Route path="/quarkus" title="Quarkus">` added to the `EntityPage.tsx`
- If you plan to use some images `<img src="myImage" .../>`, then create a `imgs` folder and move your svg files there.

### Access Kubernetes

- To access a kubernetes cluster using the app-config `kubernetes:`, add the following packages within the plugin package.json file:
```json
"@backstage/plugin-kubernetes": "0.11.3",
"@backstage/plugin-kubernetes-common": "0.7.4",
```

## Getting started

Within the root od the project, launch backstage `yarn dev`, register an existing component like [this](https://github.com/ch007m/my-quarkus-app-bk/blob/main/catalog-info.yaml) and next open the component view `http://localhost:3000/catalog/default/Component/my-quarkus-app/quarkus`

If you want to use your own `app-config.yaml` config file, then launch backstage front and backend in 2 terminal:
```bash
yarn start --config ../../app-config.local.yaml
yarn start-backend --config ../../app-config.local.yaml
```
