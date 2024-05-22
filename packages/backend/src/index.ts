import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();
backend.add(import('@backstage/plugin-auth-backend'));
backend.add(import('@backstage/plugin-auth-backend-module-guest-provider'));

backend.add(import('@backstage/plugin-app-backend/alpha'));
backend.add(import('@backstage/plugin-catalog-backend-module-unprocessed'));
backend.add(
    import('@backstage/plugin-catalog-backend-module-scaffolder-entity-model'),
);
backend.add(import('@backstage/plugin-catalog-backend/alpha'));

backend.add(import('@backstage/plugin-permission-backend/alpha'));
backend.add(import('@backstage/plugin-proxy-backend/alpha'));
backend.add(import('@backstage/plugin-scaffolder-backend/alpha'));
backend.add(import('@backstage/plugin-scaffolder-backend-module-github'));
backend.add(import('@backstage/plugin-search-backend-module-catalog/alpha'));
backend.add(import('@backstage/plugin-search-backend-module-techdocs/alpha'));
backend.add(import('@backstage/plugin-search-backend/alpha'));
backend.add(import('@backstage/plugin-techdocs-backend/alpha'));
backend.add(import('@backstage/plugin-notifications-backend'));
backend.add(import('@backstage/plugin-kubernetes-backend/alpha'));

backend.add(import('@backstage/plugin-permission-backend-module-allow-all-policy'));

// Argocd
backend.add(import('./plugins/argocd-backend/index'))
backend.add(import('./plugins/argocd-actions/index'))

// Qshift
backend.add(import('./plugins/qshift-actions/index'))

// TODO: Section to be reviewed to add/remove plugins
// //backend.add(import('@backstage/plugin-signals-backend'));
// backend.add(import('@backstage/plugin-catalog-backend-module-backstage-openapi'));
// backend.add(import('@backstage/plugin-search-backend-module-explore/alpha'));
// backend.add(import('@backstage/plugin-permission-backend/alpha'));

// TODO: To be added in a separate PR: backend.add(import('@backstage/plugin-devtools-backend'));
// TODO: Add the github auth provider as janus-idp is using it

backend.start()
