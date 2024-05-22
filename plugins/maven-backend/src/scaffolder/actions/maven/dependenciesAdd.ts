import {createTemplateAction} from '@backstage/plugin-scaffolder-node';
import {examples} from "./dependenciesAdd.example";
import fs from 'fs-extra';
import {resolveSafeChildPath} from '@backstage/backend-common';
import { DOMParser, XMLSerializer } from 'xmldom';
import formatter from 'xml-formatter';

export const mavenDependenciesAdd = () => {
  return createTemplateAction<{ url: string; targetPath: string, values: any }>({
    id: 'maven:dependencies:add',
    description: 'Add a maven dependency to the pom.xml file',
    examples,
    schema: {
      input: {
        type: 'object',
        properties: {
          pomPath: {
            title: 'pomPath',
            description: 'The path to the pom.xml file',
            type: 'string',
            default: 'pom.xml'
          },
          dependencies: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                groupId: {
                  title: 'groupId',
                  description: 'The maven groupId',
                  type: 'string'
                },
                artifactId: {
                  title: 'artifactId',
                  description: 'The maven artifactId',
                  type: 'string'
                },
                version: {
                  title: 'version',
                  description: 'The maven version',
                  type: 'string'
                },
                classifier: {
                  title: 'classifier',
                  description: 'The maven classifier',
                  type: 'string'
                },
                scope: {
                  title: 'scope',
                  description: 'The maven scope',
                  type: 'enum',
                  enum: ['compile', 'provided', 'runtime', 'test', 'system', 'import']
                },
                optional: {
                  title: 'optional',
                  description: 'The maven optional',
                  type: 'boolean'
                },
              },
              required: ['groupId', 'artifactId'],
            },
          },
        },
      },
    },

    async handler(ctx) {
        const pomPath = resolveSafeChildPath(ctx.workspacePath, ctx.input.values.pomPath ?? 'pom.xml');
        console.log(`Adding dependencies to: ${pomPath}`);
        if (!fs.existsSync(pomPath)) {
          throw new Error(`File ${pomPath} not found`);
        }
        
        const pomContent = fs.readFileSync(pomPath, 'utf8');
        const pomXml = new DOMParser().parseFromString(pomContent, 'text/xml');
        const project = pomXml.documentElement;
        const dependencies = Array.from(project.childNodes).find((node: any) => node.nodeName === 'dependencies') 
        ?? pomXml.createElement('dependencies');

        ctx.input.values.dependencies.forEach((dep: any) => {
          console.log(`Adding dependency: ${dep.groupId}:${dep.artifactId}`, (dep.version ? `:${dep.version}` : ''));
          const dependency = pomXml.createElement('dependency');
          const groupId = pomXml.createElement('groupId');
          groupId.textContent = dep.groupId;
          dependency.appendChild(groupId);
          const artifactId = pomXml.createElement('artifactId');
          artifactId.textContent = dep.artifactId;
          dependency.appendChild(artifactId);

          if (dep.version) {
            const version = pomXml.createElement('version');
            version.textContent = dep.version;
            dependency.appendChild(version);
          }

          if (dep.classifier) {
            const classifier = pomXml.createElement('classifier');
            classifier.textContent = dep.classifier;
            dependency.appendChild(classifier);
          }
          if (dep.scope) {
            const scope = pomXml.createElement('scope');
            scope.textContent = dep.scope;
            dependency.appendChild(scope);
          }
          if (dep.optional) {
            const optional = pomXml.createElement('optional');
            optional.textContent = 'true';
            dependency.appendChild(optional);
          }
          dependencies.appendChild(dependency);
        });

        const serializedXml = new XMLSerializer().serializeToString(pomXml);
        const prettyXml = formatter(serializedXml, {
            indentation: '  ', // Indent using two spaces (configure as needed)
            collapseContent: true, // Useful for elements with lots of whitespace
            lineSeparator: '\n' // Use newline for line breaks
        });
        fs.writeFileSync(pomPath, prettyXml);
    },
  });
};


