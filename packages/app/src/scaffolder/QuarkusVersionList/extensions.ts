import { scaffolderPlugin } from '@backstage/plugin-scaffolder';
import { createScaffolderFieldExtension } from '@backstage/plugin-scaffolder-react';
import QuarkusVersionList from "./QuarkusVersionList"; // Version[] as within plugin project

export const QuarkusVersionListField = scaffolderPlugin.provide(
    createScaffolderFieldExtension({
        name: 'QuarkusVersionList',
        component: QuarkusVersionList,
    }),
);