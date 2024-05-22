import { UrlReader, resolveSafeChildPath } from '@backstage/backend-common';
import { promises as fs } from 'fs-extra';
import { examples } from './api.examples';
import { createTemplateAction } from '@backstage/plugin-scaffolder-node';

import { CatalogApi } from '@backstage/catalog-client';
import path from 'path';

/**
 * Gets the definition of an API and places it in the workspace, or optionally
 * in a subdirectory specified by the 'targetPath' input option.
 * @public
 */
export function createSaveApiAction(options: {
  reader: UrlReader;
  catalog: CatalogApi;
}) {
  const { reader, catalog } = options;

  return createTemplateAction<{
    apiEntityRef: string;
    targetPath: string;
  }>({
    id: 'api:save',
    description:
      'Gets the defintion of an API from the catalog and places it in the workspace.',
    examples,
    schema: {
      input: {
        type: 'object',
        required: ['apiEntityRef', 'targetPath'],
        properties: {
          apiEntityRef: {
            title: 'API Reference',
            description:
              'The API reference to fetch the definition for, in the format of "<kind>:<namespace>/<name>".',
            type: 'string',
          },
          targetPath: {
            title: 'Target Path',
            description:
              'Target path within the working directory to download the file as.',
            type: 'string',
          },
        },
      },
    },
    supportsDryRun: true,
    async handler(ctx) {
      ctx.logger.info('Fetching API definition from the catalog');

      // Finally move the template result into the task workspace
      const outputPath = resolveSafeChildPath(
        ctx.workspacePath,
        ctx.input.targetPath,
      );

      const entity = await catalog.getEntityByRef(ctx.input.apiEntityRef, {
        token: ctx.secrets?.backstageToken,
      });
      const definition = entity?.spec?.definition?.toString();
      if (!definition) {
        throw new Error('API definition not found in the catalog');
      }

      const outputDir = path.dirname(outputPath);
      await fs.mkdir(outputDir, { recursive: true });

      let content: string = definition.trim();
      if (content.startsWith('$text')) {
        const pathOrUrl = content.split('$text:')[1].trim();
        if (pathOrUrl.startsWith('http')) {
          const res = await reader.readUrl(pathOrUrl);
          content = await res
            .buffer()
            .then(b => b.toString())
            .catch(e => {
              throw new Error(`Failed to fetch from url ${pathOrUrl}, ${e}`);
            });
        } else {
          content = await fs
            .readFile(resolveSafeChildPath(ctx.workspacePath, pathOrUrl))
            .then(f => f.toString())
            .catch(e => {
              throw new Error(`Failed to fetch file ${pathOrUrl}, ${e}`);
            });
        }
      }
      await fs.writeFile(outputPath, content);
    },
  });
}
