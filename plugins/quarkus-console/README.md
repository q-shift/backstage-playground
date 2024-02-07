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
- Refactor the code to manage the data and types in separate files: `data.ts`, `type.ts`

### Access Kubernetes

- To access a kubernetes cluster using the app-config `kubernetes:`, add the following packages within the plugin package.json file:
```json
"@backstage/plugin-kubernetes": "0.11.3",
"@backstage/plugin-kubernetes-common": "0.7.4",
```
- Create under the folder `components` a new file `QuarkusComponent.tsx`. This typescript will be used as entry function to get the resources associated to an entity
```typescript
import { useK8sObjectsResponse } from '../services/useK8sObjectsResponse';
import { K8sResourcesContext } from '../services/K8sResourcesContext';

export enum ModelsPlural {
    pods = 'pods',
} 

export const QuarkusComponent = (props: any) => {
    const watchedResources = [
        ModelsPlural.pods,
    ];
    const k8sResourcesContextData = useK8sObjectsResponse(watchedResources);

    return (
        <K8sResourcesContext.Provider value={k8sResourcesContextData}>
            /* TODO */
        </K8sResourcesContext.Provider>
    );
};
```
- Create a new folder `services` where we will declare the different services able to fetch the kubernetes resources: `useK8sObjectsResponse`, `useK8sResourcesClusters`, etc
```typescript
// ./src/services/useK8sObjectsResponse
import { useState } from 'react';

import { useEntity } from '@backstage/plugin-catalog-react';
import { useKubernetesObjects } from '@backstage/plugin-kubernetes';

import { K8sResourcesContextData } from '../types/types';
import { useAllWatchResources } from './useAllWatchResources';
import { useK8sResourcesClusters } from './useK8sResourcesClusters';

export const useK8sObjectsResponse = (
    watchedResource: string[],
): K8sResourcesContextData => {
    const { entity } = useEntity();
    const { kubernetesObjects, loading, error } = useKubernetesObjects(entity);
    const [selectedCluster, setSelectedCluster] = useState<number>(0);
    const watchResourcesData = useAllWatchResources(
        watchedResource,
        { kubernetesObjects, loading, error },
        selectedCluster,
    );
    const { clusters, errors: clusterErrors } = useK8sResourcesClusters({
        kubernetesObjects,
        loading,
        error,
    });
    return {
        watchResourcesData,
        loading,
        responseError: error,
        selectedClusterErrors: clusterErrors?.[selectedCluster] ?? [],
        clusters,
        setSelectedCluster,
        selectedCluster,
    };
};
```


## Getting started

Within the root od the project, launch backstage `yarn dev`, register an existing component like [this](https://github.com/ch007m/my-quarkus-app-bk/blob/main/catalog-info.yaml) and next open the component view `http://localhost:3000/catalog/default/Component/my-quarkus-app/quarkus`

If you want to use your own `app-config.yaml` config file, then launch backstage front and backend in 2 terminal:
```bash
yarn start --config ../../app-config.local.yaml
yarn start-backend --config ../../app-config.local.yaml
```
