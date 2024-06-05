## Api actions

This plugin provides the following list of backstage action(s) to be used in a template:

| Action       | Description                                           |
|--------------|-------------------------------------------------------|
| `api:save`   | Save an API from the catalog to the project workspace |

To use this plugin, add the following packages to the backstage backend:
```bash
yarn add --cwd packages/backend "@qshift/plugin-maven-backend"
yarn add --cwd packages/backend "@backstage/integration"
```
Next, follow the instructions documented for each `action`

### api:save

To use the plugin you need to add the following module to the new backend system like this

```typescript
// packages/backend/src/index.ts
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();
...
backend.add(import('@qshift/plugin-quarkus-backend'));
...
backend.start();
```

The following table details the fields that you can use to customize this action:

| Input        | Description                              | Type   | Required |
|--------------|------------------------------------------|--------|----------|
| apiEntityRef | The reference of the Api Entity          | string | Yes      |
| targetPath   | Path where the API file should be stored | string | Yes      |


Example of template including the EntityPicker field parameter:
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

**Remark**: The apiRef example above only lists the APIs of type `grpc`, but any type can be used, or even no type at all. In the later case all APIs, regardless of their kind will be listed.

The definition of the selected API can then be saved to the project workspace using the `save:api` action.

```yaml
- id: saveApi
  name: Save the API
  action: save:api
  input:
    values:
      targetPath: proto/${{ parameters.component_id }}.proto
      apiEntityRef: ${{ parameters.apiRef }}
```
