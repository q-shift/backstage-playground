# api

This plugin provides 1 action able to:

| Action       | Description                                           |
|--------------|-------------------------------------------------------|
| `api:save`   | Save an API from the catalog to the project workspace |

To use this plugin, import the following packages under the following path:
```bash
yarn add --cwd packages/backend "@qshift/plugin-maven-backend"
yarn add --cwd packages/backend "@backstage/integration"
```

### api:save

To use the plugin you need to add the following module to your backend:

```typescript
import {
    coreServices,
    createBackendModule,
} from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node/alpha';
import { catalogServiceRef } from '@backstage/plugin-catalog-node/alpha';
import { createSaveApiAction } from '@qshift/plugin-api-backend';

export const scaffolderBackendModuleQShift = createBackendModule({
    moduleId: 'scaffolder-backend-module-qshift',
    pluginId: 'scaffolder',
    register(env) {
        env.registerInit({
            deps: {
                scaffolder: scaffolderActionsExtensionPoint,
                reader: coreServices.urlReader,
                catalog: catalogServiceRef,
            },
            async init({ scaffolder, reader, catalog }) {
                scaffolder.addActions(
                    createSaveApiAction({reader, catalog}),
                );
            },
        });
    },
});

```yaml
properties:
  apiRef:
    title: API
    description: The API to consume
    type: string
    ui:field: EntityPicker
    ui:options:
      catalogFilter:
        kind:
          - API
        spec.type: grpc
```

The example above only lists APIs of type `grpc`, but any type can be used, or even no type at all. In the later case all APIs, regardless of their kind will be listed.
The definition of the selected API can then be save to the project workspace, using the `fetch:api` action.

```yaml
- id: saveApi
  name: Save the API
  action: save:api
  input:
    values:
      targetPath: proto/${{ parameters.component_id }}.proto
      apiEntityRef: ${{ parameters.apiRef }}
```
