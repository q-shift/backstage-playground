import {
    createBackendModule,
} from '@backstage/backend-plugin-api';
import {
    scaffolderActionsExtensionPoint,
    scaffolderTemplatingExtensionPoint
} from '@backstage/plugin-scaffolder-node/alpha';
import { createQuarkusApp, cloneQuarkusQuickstart } from '@qshift/plugin-quarkus-backend';
import { extractVersionFromKey } from '@qshift/plugin-quarkus-backend';

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
                scaffolderAction: scaffolderActionsExtensionPoint,
                scaffolderFilter: scaffolderTemplatingExtensionPoint,
            },
            async init({ scaffolderAction, scaffolderFilter}) {
                scaffolderAction.addActions(
                    createQuarkusApp(),
                    cloneQuarkusQuickstart(),
                );
                scaffolderFilter.addTemplateFilters({
                     extractVersionFromKey: (streamKey) => extractVersionFromKey(streamKey as string),
                  },
                );
            },
        });
    },
});
