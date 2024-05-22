import { TemplateExample } from '@backstage/plugin-scaffolder-node';
import yaml from 'yaml';

export const examples: TemplateExample[] = [
  {
    description: 'Gets API definition and places it in the workspace.',
    example: yaml.stringify({
      steps: [
        {
          action: 'api:save',
          id: 'save-api',
          name: 'Save API',
          input: {
            apiEntityRef: 'api:default/foo',
          },
        },
      ],
    }),
  },
];
