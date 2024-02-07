import React from 'react';
import { createDevApp } from '@backstage/dev-utils';
import { quarkusConsolePlugin, QuarkusConsolePage } from '../src/plugin';

createDevApp()
  .registerPlugin(quarkusConsolePlugin)
  .addPage({
    element: <QuarkusConsolePage />,
    title: 'Root Page',
    path: '/quarkus-console'
  })
  .render();
