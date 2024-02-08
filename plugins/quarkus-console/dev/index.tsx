import React from 'react';
import { createDevApp } from '@backstage/dev-utils';
import { QuarkusConsolePlugin, QuarkusConsolePage } from '../src/plugin';

createDevApp()
  .registerPlugin(QuarkusConsolePlugin)
  .addPage({
    element: <QuarkusConsolePage />,
    title: 'Root Page',
    path: '/quarkus-console'
  })
  .render();
