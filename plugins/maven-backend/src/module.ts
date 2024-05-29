import {
    createBackendModule,
} from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node/alpha';
import { mavenDependenciesAdd } from '@qshift/plugin-maven-backend';

/**
 * @public
 * The Maven Module for the Scaffolder Backend
 */
export const mavenModule = createBackendModule({
    moduleId: 'scaffolder-backend-module-qshift',
    pluginId: 'scaffolder',
    register(env) {
        env.registerInit({
            deps: {
                scaffolder: scaffolderActionsExtensionPoint,
            },
            async init({ scaffolder }) {
                scaffolder.addActions(
                    mavenDependenciesAdd(),
                );
            },
        });
    },
});
