import {
    coreServices,
    createBackendModule,
} from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node/alpha';
import { catalogServiceRef } from '@backstage/plugin-catalog-node/alpha';
import { createQuarkusApp, cloneQuarkusQuickstart } from '@qshift/plugin-quarkus-backend';
import { mavenDependenciesAdd } from '@qshift/plugin-maven-backend';
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
                    createQuarkusApp(),
                    cloneQuarkusQuickstart(),
                    mavenDependenciesAdd(),
                    createSaveApiAction({reader, catalog}),
                );
            },
        });
    },
});
