import {
    createBackendModule,
} from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node/alpha';
import { createQuarkusApp, cloneQuarkusQuickstart } from '@qshift/plugin-quarkus-backend';

/**
 * @public
 * The Quarkus Module for the Scaffolder Backend
 */
export const quarkusModule = createBackendModule({
    moduleId: 'quarkus',
    pluginId: 'scaffolder',
    register(env) {
        env.registerInit({
            deps: {
                scaffolder: scaffolderActionsExtensionPoint,
            },
            async init({ scaffolder}) {
                scaffolder.addActions(
                    createQuarkusApp(),
                    cloneQuarkusQuickstart(),
                );
            },
        });
    },
});
