import {
    coreServices,
    createBackendModule,
} from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node/alpha';
import { catalogServiceRef } from '@backstage/plugin-catalog-node/alpha';
import { createSaveApiAction } from '@qshift/plugin-api-backend';

/**
 * @public
 * The Api Module for the Scaffolder Backend
 */
export const apiModule = createBackendModule({
    moduleId: 'api',
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
