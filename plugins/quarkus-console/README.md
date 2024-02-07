# quarkus-console

Welcome to the quarkus-console plugin!

_This plugin was created through the Backstage CLI_

## HowTo guide

The section describes the different steps followed to create the plugin and integrates it with kubernetes/ocp

- New plugin created using command ` yarn new --select plugin` and using as id `quarkus-console`
- Example generated has been renamed to `src/components/QuarkusConsole` and `src/components/QuarkusConsoleFetch`
- Type definition and example have been refactyored to return a `TableColumn` with dummy records
- New module added to the `packages/app/packages.json` => `"@internal/plugin-quarkus-console": "^0.1.0",`
- Quarkus icon created (QuarkusIcon.tsx) using `MUI: SvgIcon & SvgIconProps)`
- New `<SidebarItem icon={QuarkusIcon} to="quarkus" text="Quarkus" />` added to `src/components/Root/Root.tsx`
- New `<EntityLayout.Route path="/quarkus" title="Quarkus">` added to the `EntityPage.tsx` 
- 

## Getting started

Your plugin has been added to the example app in this repository, meaning you'll be able to access it by running `yarn start` in the root directory, and then navigating to [/quarkus-console](http://localhost:3000/quarkus-console).

You can also serve the plugin in isolation by running `yarn start` in the plugin directory.
This method of serving the plugin provides quicker iteration speed and a faster startup and hot reloads.
It is only meant for local development, and the setup for it can be found inside the [/dev](./dev) directory.
