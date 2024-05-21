import {createTemplateAction} from '@backstage/plugin-scaffolder-node';
import {examples} from "./dependencyAdd.example";
import fs from 'fs-extra';
import {resolveSafeChildPath} from '@backstage/backend-common';
import { DOMParser, XMLSerializer } from 'xmldom';
import formatter from 'xml-formatter';

export const mavenDependencyAdd = () => {
  return createTemplateAction<{ url: string; targetPath: string, values: any }>({
    id: 'maven:dependency:add',
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
      },
    },

    async handler(ctx) {
        const pomPath = resolveSafeChildPath(ctx.workspacePath, ctx.input.values.pomPath ?? 'pom.xml');
        if (!fs.existsSync(pomPath)) {
          throw new Error(`File ${pomPath} not found`);
        }
        
        const pomContent = fs.readFileSync(pomPath, 'utf8');
        const pomXml = new DOMParser().parseFromString(pomContent, 'text/xml');
        const project = pomXml.documentElement;
        const dependencies = Array.from(project.childNodes).find((node: any) => node.nodeName === 'dependencies') 
        ?? pomXml.createElement('dependencies');
        const dependency = pomXml.createElement('dependency');
        const groupId = pomXml.createElement('groupId');
        groupId.textContent = ctx.input.values.groupId;
        dependency.appendChild(groupId);
        const artifactId = pomXml.createElement('artifactId');
        artifactId.textContent = ctx.input.values.artifactId;
        dependency.appendChild(artifactId);
        const version = pomXml.createElement('version');
        version.textContent = ctx.input.values.version;
        dependency.appendChild(version);
        if (ctx.input.values.classifier) {
          const classifier = pomXml.createElement('classifier');
          classifier.textContent = ctx.input.values.classifier;
          dependency.appendChild(classifier);
        }
        if (ctx.input.values.scope) {
          const scope = pomXml.createElement('scope');
          scope.textContent = ctx.input.values.scope;
          dependency.appendChild(scope);
        }
        if (ctx.input.values.optional) {
          const optional = pomXml.createElement('optional');
          optional.textContent = 'true';
          dependency.appendChild(optional);
        }
        dependencies.appendChild(dependency);
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
