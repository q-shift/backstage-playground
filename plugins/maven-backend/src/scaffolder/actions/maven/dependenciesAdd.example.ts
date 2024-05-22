import {TemplateExample} from '@backstage/plugin-scaffolder-node';
import yaml from 'yaml';

export const examples: TemplateExample[] = [
    {
        description: 'Add a maven dependencies to a project',
        example: yaml.stringify({
            steps: [
                {
                    action: 'maven:dependencies:add',
                    id: 'maven-dependency-add',
                    name: 'Add a dependency to a Maven project',
                    input: {
                        values: {
                            dependencies: [{
                              groupId: 'org.mvnpm.at.mvnpm',
                              artifactId: 'vaadin-webcomponents',
                              version: '24.3.10',
                              scope: 'provided',
                            }],
                        },
                    },
                },
            ],
        }),
    },
];
